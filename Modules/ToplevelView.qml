pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
import qs.Services

Loader {
    id: root

    active: false

    property bool searchAll: false

    property var toplevelPrefixes: []
    property string typedKeys: ""
    property bool saveModeActive: false
    property var targetToplevel: null
    property var storedSlots: ({})
    property var toplevels: []
    property var workspaceGroups: []
    property var allToplevels: []
    property int currentIndex: -1

    function generateUniquePrefixes(items) {
        let prefixes = new Array(items.length).fill("");

        // 1. Find which slot keys are active (i.e. the window is currently open)
        // Normalize addresses by stripping any leading '0x' for comparison
        function normalizeAddr(a) { return a ? a.replace(/^0x/i, '') : ''; }

        let addressToSlot = {};
        for (let slotKey in root.storedSlots) {
            let addr = normalizeAddr(root.storedSlots[slotKey]);
            addressToSlot[addr] = slotKey;
        }

        // Assign the slot keys as prefixes first
        for (let i = 0; i < items.length; i++) {
            let addr = normalizeAddr(items[i].address);
            if (addressToSlot[addr]) {
                prefixes[i] = addressToSlot[addr];
            }
        }

        // 2. Clean titles for the remaining items
        let cleanTitles = items.map(t => {
            let title = (t?.wayland?.title || t?.wayland?.appId || "unknown").toLowerCase();
            // Only allow alpha characters (a-z)
            return title.replace(/[^a-z]/g, '');
        });

        // 3. Generate unique prefixes sequentially
        for (let i = 0; i < items.length; i++) {
            if (prefixes[i] !== "") continue; // Already assigned via slot

            let title = cleanTitles[i];
            if (title === "") {
                prefixes[i] = "unknown";
                continue;
            }

            let len = 1;
            let maxLen = 3; // Limit prefix to 3 characters max
            while (len <= title.length && len <= maxLen) {
                let prefix = title.substring(0, len);
                let conflict = false;

                // Check conflict ONLY with exact matches of already assigned prefixes
                for (let j = 0; j < items.length; j++) {
                    if (prefixes[j] === prefix) {
                        conflict = true;
                        break;
                    }
                }

                // Also check conflict with any stored slot keys that are NOT currently open
                if (!conflict) {
                    for (let slotKey in root.storedSlots) {
                        if (slotKey === prefix) {
                            if (root.storedSlots[slotKey] !== items[i].address) {
                                conflict = true;
                                break;
                            }
                        }
                    }
                }

                if (!conflict) {
                    prefixes[i] = prefix;
                    break;
                }
                len++;
            }
            if (prefixes[i] === "") {
                prefixes[i] = title.substring(0, maxLen);
            }
        }

        return prefixes;
    }

    function updateToplevels() {
        if (!Hyprland.toplevels)
            return;
        if (!Hyprland.focusedWorkspace)
            return;

        workspaceGroups = Hyprland.toplevels.values.reduce((groups, toplevel) => {
            var workspaceId = toplevel?.workspace?.id;
            if (workspaceId === undefined || workspaceId === null || workspaceId === Hyprland.focusedWorkspace?.id) {
                return groups;
            }
            if (!groups[workspaceId]) {
                groups[workspaceId] = [];
            }
            groups[workspaceId].push(toplevel);
            return groups;
        }, {});
        toplevels = Hyprland.toplevels.values.filter(toplevel => toplevel?.workspace?.id === Hyprland.focusedWorkspace?.id);
        allToplevels = toplevels.concat(Object.keys(workspaceGroups).sort((a, b) => parseInt(a) - parseInt(b)).map(id => workspaceGroups[id]).reduce((acc, arr) => acc.concat(arr), []));
        currentIndex = toplevels.findIndex(toplevel => toplevel.activated);
        if (currentIndex === -1 && toplevels.length > 0) {
            currentIndex = 0;
        }

        toplevelPrefixes = generateUniquePrefixes(allToplevels);
    }

    onActiveChanged: {
        if (!active) {
            typedKeys = "";
            saveModeActive = false;
            targetToplevel = null;
        }
    }

    FileViewPlus {
        id: persistentSlots
        path: Qt.resolvedUrl('../Settings/.data/toplevel_slots.json')
        defaultValue: ({})
        onDataLoaded: parsed => {
            root.storedSlots = parsed;
            root.updateToplevels();
        }
    }

    Component.onCompleted: updateToplevels()

    Connections {
        target: Hyprland.toplevels
        function onValuesChanged() {
            root.updateToplevels();
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.updateToplevels();
        }
    }

    GlobalShortcut {
        name: "toplevelview"
        onPressed: {
            hideTimer.restart();
            root.updateToplevels();
            if (!root.active) {
                root.active = true;
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.active = false
    }

    sourceComponent: PanelWindow {
        id: toplevelView

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.namespace: "toplevels"
        WlrLayershell.layer: WlrLayer.Overlay

        mask: Region {
            item: offMonitorBar
        }

        function getToplevelIndex(toplevel) {
            return root.allToplevels.indexOf(toplevel);
        }

        HyprlandFocusGrab {
            active: root.active
            windows: [toplevelView]
            onCleared: root.active = false
        }

        Rectangle {
            id: offMonitorBar

            visible: Object.keys(root.workspaceGroups).length > 0

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: Styles.marginLg * 2

            width: offMonitorFlow.implicitWidth + Styles.marginSm
            height: offMonitorFlow.implicitHeight + Styles.marginSm

            color: Colors.surfaceLighter
            radius: Styles.radiusMd

            GridLayoutPlus {
                id: offMonitorFlow
                anchors.centerIn: parent
                model: Object.keys(root.workspaceGroups).sort((a, b) => parseInt(a) - parseInt(b))
                delegate: ColumnLayout {
                    id: offMonitorToplevel

                    spacing: Styles.marginSm

                    Layout.alignment: Qt.AlignTop

                    required property var modelData
                    property var workspaceToplevels: root.workspaceGroups[modelData] ?? []

                    Rectangle {
                        Layout.preferredHeight: workspaceId.implicitHeight + Styles.marginSm
                        Layout.fillWidth: true
                        radius: Styles.radiusMd
                        color: Colors.surface
                        TextStyled {
                            id: workspaceId
                            anchors.fill: parent
                            font.pointSize: Styles.textSm
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: "󰜌 " + offMonitorToplevel.modelData
                        }
                    }

                    ColumnLayoutPlus {
                        model: parent.workspaceToplevels
                        delegate: ButtonStyled {
                            id: offMonitor

                            required property var modelData
                            required property int index

                            implicitWidth: 175
                            implicitHeight: 50
                            isFocused: modelData.activated

                            onClicked: modelData.wayland.activate()

                            property int globalIndex: toplevelView.getToplevelIndex(modelData)
                            property string keyLabel: globalIndex >= 0 && globalIndex < root.toplevelPrefixes.length ? root.toplevelPrefixes[globalIndex] : ""
                            property string matchedPart: root.typedKeys !== "" && keyLabel.startsWith(root.typedKeys) ? root.typedKeys : ""
                            property string unmatchedPart: matchedPart !== "" ? keyLabel.substring(matchedPart.length) : keyLabel

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Styles.marginSm
                                IconImage {
                                    implicitHeight: 32
                                    implicitWidth: 32
                                    source: Quickshell.iconPath(DesktopEntries.byId(offMonitor.modelData.wayland?.appId)?.icon, "applications-other")
                                }
                                Rectangle {
                                    Layout.preferredHeight: textRow.implicitHeight + Styles.marginSm
                                    Layout.preferredWidth: Math.max(30, textRow.implicitWidth + Styles.marginSm)
                                    color: Colors.surfaceLighter
                                    radius: Styles.radiusLg
                                    Row {
                                        id: textRow
                                        anchors.centerIn: parent
                                        TextStyled {
                                            text: offMonitor.matchedPart.toUpperCase()
                                            color: Colors.primary
                                            font.bold: true
                                            font.pointSize: Styles.textSm
                                        }
                                        TextStyled {
                                            text: offMonitor.unmatchedPart.toUpperCase()
                                            color: Colors.onSurface
                                            font.pointSize: Styles.textSm
                                        }
                                    }
                                }
                                TextStyled {
                                    Layout.fillWidth: true
                                    text: (offMonitor.modelData?.wayland?.title ?? "Unknown App")
                                    elide: Text.ElideRight
                                    font.pointSize: Styles.textSm
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: workspaceInput
            visible: false
            anchors.top: offMonitorBar.bottom
            anchors.horizontalCenter: offMonitorBar.horizontalCenter
            anchors.margins: Styles.marginSm
            color: Colors.surfaceLighter
            width: 50
            height: 50
            radius: Styles.radiusMd
            TextFieldStyled {
                id: workspaceInputField
                placeholderText: 'workspace'
                backgroundColor: Colors.surface
                anchors.fill: parent
                Keys.onEscapePressed: root.active = false;
                Keys.onReturnPressed: event => {
                    const ctrlHeld = event.modifiers & Qt.ControlModifier;
                    const shiftHeld = event.modifiers & Qt.ShiftModifier;
                    var lua;
                    if (ctrlHeld) {
                        lua = 'hl.dsp.window.move({ workspace = "' + text + '" })';
                    } else if (shiftHeld) {
                        lua = 'hl.dsp.window.move({ workspace = "' + text + '", silent = true })';
                    } else {
                        lua = 'hl.dsp.focus({ workspace = "' + text + '" })';
                    }
                    Quickshell.execDetached(["hyprctl", "dispatch", lua]);
                    root.active = false;
                }
            }
        }

        Repeater {
            model: root.toplevels.filter(toplevel => toplevel?.workspace?.id === Hyprland.focusedWorkspace?.id)
            delegate: Rectangle {
                id: onScreen

                required property var modelData
                required property int index

                property int globalIndex: toplevelView.getToplevelIndex(modelData)
                property string keyLabel: globalIndex >= 0 && globalIndex < root.toplevelPrefixes.length ? root.toplevelPrefixes[globalIndex] : ""
                property string matchedPart: root.typedKeys !== "" && keyLabel.startsWith(root.typedKeys) ? root.typedKeys : ""
                property string unmatchedPart: matchedPart !== "" ? keyLabel.substring(matchedPart.length) : keyLabel

                property ClientInfo clientInfo: HyprctlClients.clients.find(client => modelData.address === client.address.replace('0x', ''))
                property var clientMonitor: Hyprland.monitors.values.find(monitor => monitor.id === clientInfo?.monitor)

                width: 80
                height: 60

                x: clientInfo ? clientInfo.at[0] - (clientMonitor?.x ?? 0) + clientInfo.size[0] / 2 - width / 2 : 0
                y: clientInfo ? clientInfo.at[1] - (clientMonitor?.y ?? 0) + clientInfo.size[1] / 2 - height / 2 : 0

                color: modelData.activated ? Colors.surfaceLighter: Colors.surface
                radius: Styles.radiusMd

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    IconImage {
                        implicitHeight: 32
                        implicitWidth: 32
                        source: Quickshell.iconPath(DesktopEntries.byId(onScreen.modelData.wayland?.appId)?.icon, "applications-other")
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Row {
                            TextStyled {
                                text: onScreen.matchedPart.toUpperCase()
                                color: Colors.primary
                                font.bold: true
                                font.pointSize: Styles.textSm
                            }
                            TextStyled {
                                text: onScreen.unmatchedPart.toUpperCase()
                                color: Colors.onSurface
                                font.pointSize: Styles.textSm
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: slotsPanel
            visible: Object.keys(root.storedSlots).some(key => {
                var addr = (root.storedSlots[key] ?? "").replace(/^0x/i, '');
                return root.allToplevels.some(t => t.address.replace(/^0x/i, '') === addr);
            })
            anchors.bottom: saveModeBanner.visible ? saveModeBanner.top : parent.bottom
            anchors.right: parent.right
            anchors.margins: Styles.marginLg * 2
            width: slotsColumn.implicitWidth + Styles.marginSm * 2
            height: slotsColumn.implicitHeight + Styles.marginSm * 2
            color: Colors.surfaceLighter
            radius: Styles.radiusMd

            ColumnLayout {
                id: slotsColumn
                anchors.centerIn: parent
                spacing: Styles.marginSm

                RowLayout {
                    Layout.fillWidth: true
                    TextStyled {
                        text: "Saved Slots"
                        font.pointSize: Styles.textSm
                        color: Colors.outline
                        Layout.fillWidth: true
                    }
                    ButtonStyled {
                        text: "󰌍"
                        implicitWidth: 24
                        implicitHeight: 24
                        pointSize: Styles.textSm
                        defaultColor: Colors.errorContainer
                        textColor: Colors.onErrorContainer
                        onClicked: {
                            root.storedSlots = {};
                            persistentSlots.save(root.storedSlots);
                            root.updateToplevels();
                        }
                    }
                }

                Repeater {
                    model: Object.keys(root.storedSlots).sort().filter(key => {
                        var addr = (root.storedSlots[key] ?? "").replace(/^0x/i, '');
                        return root.allToplevels.some(t => t.address.replace(/^0x/i, '') === addr);
                    })
                    delegate: RowLayout {
                        id: slotRow
                        required property var modelData
                        property string slotKey: modelData
                        property string slotAddress: root.storedSlots[modelData] ?? ""
                        property var slotToplevel: root.allToplevels.find(t => t.address.replace(/^0x/i, '') === slotAddress.replace(/^0x/i, '')) ?? null

                        Layout.fillWidth: true
                        spacing: Styles.marginSm

                        Rectangle {
                            implicitWidth: slotKeyText.implicitWidth + Styles.marginSm * 2
                            implicitHeight: slotKeyText.implicitHeight + Styles.marginSm
                            color: Colors.primary
                            radius: Styles.radiusLg
                            TextStyled {
                                id: slotKeyText
                                anchors.centerIn: parent
                                text: slotRow.slotKey.toUpperCase()
                                color: Colors.onPrimary
                                font.pointSize: Styles.textSm
                            }
                        }

                        IconImage {
                            implicitWidth: 20
                            implicitHeight: 20
                            source: {
                                var t = slotRow.slotToplevel;
                                return t ? Quickshell.iconPath(DesktopEntries.byId(t.wayland?.appId)?.icon, "applications-other") : "";
                            }
                        }

                        TextStyled {
                            Layout.fillWidth: true
                            font.pointSize: Styles.textSm
                            elide: Text.ElideRight
                            text: slotRow.slotToplevel ? (slotRow.slotToplevel.wayland?.title ?? "Unknown") : "(closed)"
                            color: slotRow.slotToplevel ? Colors.onSurface : Colors.outline
                        }

                        ButtonStyled {
                            text: "󰅖"
                            implicitWidth: 24
                            implicitHeight: 24
                            pointSize: Styles.textSm
                            defaultColor: Colors.surface
                            textColor: Colors.onSurface
                            onClicked: {
                                var newSlots = Object.assign({}, root.storedSlots);
                                delete newSlots[slotRow.slotKey];
                                root.storedSlots = newSlots;
                                persistentSlots.save(root.storedSlots);
                                root.updateToplevels();
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: saveModeBanner
            visible: root.saveModeActive
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: Styles.marginLg * 2
            width: bannerText.implicitWidth + Styles.marginLg * 2
            height: bannerText.implicitHeight + Styles.marginSm * 2
            color: Colors.primary
            radius: Styles.radiusMd

            TextStyled {
                id: bannerText
                anchors.centerIn: parent
                text: root.targetToplevel === null 
                    ? "SAVE MODE: Press a window key..." 
                    : "SAVE MODE: Press an alias key (a-z) to assign to '" + (root.targetToplevel?.wayland?.title ?? "App") + "'"
                color: Colors.onPrimary
                font.bold: true
                font.pointSize: Styles.textMd
            }
        }

        Rectangle {
            id: controller

            anchors.fill: parent
            color: "transparent"
            focus: true

            Keys.onPressed: function (event) {
                hideTimer.restart();

                if (event.key === Qt.Key_Control) {
                    root.saveModeActive = !root.saveModeActive;
                    root.targetToplevel = null;
                    root.typedKeys = "";
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Backspace) {
                    root.storedSlots = {};
                    persistentSlots.save(root.storedSlots);
                    root.updateToplevels();
                    event.accepted = true;
                    return;
                }

                if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                    var matchIndex = root.toplevelPrefixes.indexOf(root.typedKeys);
                    if (matchIndex !== -1) {
                        var toplevel = root.allToplevels[matchIndex].wayland;
                        root.active = false;
                        root.typedKeys = "";
                        toplevel.activate();
                        event.accepted = true;
                        return;
                    }
                }

                if ([Qt.Key_Escape].includes(event.key)) { // Quit
                    if (root.saveModeActive) {
                        root.saveModeActive = false;
                        root.targetToplevel = null;
                        root.typedKeys = "";
                        event.accepted = true;
                        return;
                    }
                    root.active = false;
                    root.typedKeys = "";
                    event.accepted = true;
                    return;
                }

                if (root.saveModeActive) {
                    var pressedChar = event.text.toLowerCase();
                    if (pressedChar === "" || !/^[a-z]$/.test(pressedChar))
                        return;

                    event.accepted = true;

                    if (root.targetToplevel === null) {
                        root.typedKeys += pressedChar;

                        // Only select when the typed keys match exactly one prefix
                        var exactIndex = root.toplevelPrefixes.indexOf(root.typedKeys);
                        var stillAmbiguous = root.toplevelPrefixes.some(p => p !== root.typedKeys && p.startsWith(root.typedKeys));
                        if (exactIndex !== -1 && !stillAmbiguous) {
                            root.targetToplevel = root.allToplevels[exactIndex];
                            root.typedKeys = "";
                            return;
                        }

                        var hasPotentialMatch = root.toplevelPrefixes.some(p => p.startsWith(root.typedKeys));
                        if (!hasPotentialMatch) {
                            root.typedKeys = pressedChar;
                            exactIndex = root.toplevelPrefixes.indexOf(root.typedKeys);
                            stillAmbiguous = root.toplevelPrefixes.some(p => p !== root.typedKeys && p.startsWith(root.typedKeys));
                            if (exactIndex !== -1 && !stillAmbiguous) {
                                root.targetToplevel = root.allToplevels[exactIndex];
                                root.typedKeys = "";
                            }
                        }
                    } else {
                        var newSlots = Object.assign({}, root.storedSlots);
                        newSlots[pressedChar] = root.targetToplevel.address;
                        root.storedSlots = newSlots;
                        persistentSlots.save(root.storedSlots);
                        root.saveModeActive = false;
                        root.targetToplevel = null;
                        root.typedKeys = "";
                        root.updateToplevels();
                    }
                    return;
                }

                if (event.text.match(/[0-9-+]/) !== null) { // Workspace input
                    workspaceInputField.text = event.text;
                    workspaceInput.visible = true;
                    workspaceInputField.focus = true;
                    return;
                } else { // Select a window
                    var pressedChar = event.text.toLowerCase();
                    if (pressedChar === "" || !/^[a-z]$/.test(pressedChar))
                        return;

                    root.typedKeys += pressedChar;
                    event.accepted = true;

                    // Activate when typed keys exactly match a prefix and no other prefix starts with it
                    var matchIndex = root.toplevelPrefixes.indexOf(root.typedKeys);
                    var isAmbiguous = root.toplevelPrefixes.some(p => p !== root.typedKeys && p.startsWith(root.typedKeys));
                    if (matchIndex !== -1 && !isAmbiguous) {
                        var toplevel = root.allToplevels[matchIndex].wayland;
                        root.active = false;
                        root.typedKeys = "";
                        toplevel.activate();
                        return;
                    }

                    // If Enter is pressed, force-activate the first match
                    // (handled separately via Qt.Key_Return above)

                    // Check if typedKeys is no longer a prefix of any window's prefix.
                    var hasPotentialMatch = root.toplevelPrefixes.some(p => p.startsWith(root.typedKeys));
                    if (!hasPotentialMatch) {
                        // Reset typedKeys to the last pressed char to see if it starts a new match
                        root.typedKeys = pressedChar;
                        matchIndex = root.toplevelPrefixes.indexOf(root.typedKeys);
                        isAmbiguous = root.toplevelPrefixes.some(p => p !== root.typedKeys && p.startsWith(root.typedKeys));
                        if (matchIndex !== -1 && !isAmbiguous) {
                            var toplevel = root.allToplevels[matchIndex].wayland;
                            root.active = false;
                            root.typedKeys = "";
                            toplevel.activate();
                        }
                    }
                }
            }
        }
    }
}
