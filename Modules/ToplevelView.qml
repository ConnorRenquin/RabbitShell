pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Helpers
import qs.Components
import qs.Services
import qs.Services.Models

Loader {
    id: root

    active: false

    property bool searchAll: false

    property string typedKeys: ""
    property bool saveModeActive: false
    property bool deleteModeActive: false
    property var targetToplevel: null
    property var pendingActivation: null
    property var storedSlots: ({})
    property var toplevels: []
    property var workspaceGroups: []
    property var allToplevels: []
    property int currentIndex: -1

    property var hotkeys: []

    function getHotkey(toplevel) {
        const existing = hotkeys.find(h => h.toplevel === toplevel);
        if (existing) return existing.hotkey;
        const hotkey = generateHotkey(toplevel, hotkeys);
        setHotkey(toplevel, hotkey, false);
        return hotkey;
    }

    // assigned: array of already-committed {hotkey} entries to check against.
    // Passing it explicitly avoids relying on root.hotkeys mid-update.
    function generateHotkey(toplevel, assigned) {
        const useAppId = Settings.get('toplevelLabel')?.value === 'appId';
        const raw = useAppId
            ? (toplevel?.wayland?.appId || toplevel?.wayland?.title || "unknown")
            : (toplevel?.wayland?.title || toplevel?.wayland?.appId || "unknown");
        const name = raw.toLowerCase().replace(/[^a-z]/g, '') || "unknown";

        const taken = key =>
            assigned.some(h => h.hotkey === key) ||
            Object.keys(root.storedSlots).some(k =>
                k === key && normalizeAddr(root.storedSlots[k]) !== normalizeAddr(toplevel.address)
            );

        for (let len = 1; len <= Math.min(2, name.length); len++) {
            const prefix = name.substring(0, len);
            if (!taken(prefix)) return prefix;
        }

        const base = name.substring(0, Math.min(2, name.length));
        for (let i = 0; i < 26; i++) {
            const prefix = base + String.fromCharCode(97 + i);
            if (!taken(prefix)) return prefix;
        }

        return name.substring(0, 3) || "unk";
    }

    function setHotkey(toplevel, hotkey, persist) {
        const idx = hotkeys.findIndex(h => h.toplevel === toplevel);
        const next = [...hotkeys];
        const entry = { toplevel, hotkey, persist };
        if (idx !== -1) {
            next[idx] = entry;
        } else {
            next.push(entry);
        }
        hotkeys = next;
    }

    function removeHotkey(toplevel) {
        hotkeys = hotkeys.filter(h => h.toplevel !== toplevel);
    }

    function normalizeAddr(a) { return a ? a.replace(/^0x/i, '') : ''; }

    function toplevelLabel(toplevel) {
        const useAppId = Settings.get('toplevelLabel')?.value === 'appId';
        return useAppId
            ? (toplevel?.wayland?.appId ?? "Unknown App")
            : (toplevel?.wayland?.title ?? "Unknown App");
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
        const sortedOtherToplevels = Object.keys(workspaceGroups)
            .sort((a, b) => parseInt(a) - parseInt(b))
            .map(id => workspaceGroups[id])
            .reduce((acc, arr) => acc.concat(arr), []);
        allToplevels = toplevels.concat(sortedOtherToplevels);
        currentIndex = toplevels.findIndex(toplevel => toplevel.activated);
        if (currentIndex === -1 && toplevels.length > 0) {
            currentIndex = 0;
        }

        // Build into a local array so conflict checks are always against a
        // consistent snapshot rather than the QML property mid-mutation.
        const newHotkeys = [];

        // Pass 1: persisted slot hotkeys first so auto-gen sees them as taken
        for (const t of allToplevels) {
            const addr = normalizeAddr(t.address);
            for (const key in root.storedSlots) {
                if (normalizeAddr(root.storedSlots[key]) === addr) {
                    newHotkeys.push({ toplevel: t, hotkey: key, persist: true });
                    break;
                }
            }
        }

        // Pass 2: auto-generate for everything else
        for (const t of allToplevels) {
            if (newHotkeys.some(h => h.toplevel === t)) continue;
            const hotkey = generateHotkey(t, newHotkeys);
            newHotkeys.push({ toplevel: t, hotkey, persist: false });
        }

        hotkeys = newHotkeys;
    }

    // Appends char to typedKeys and returns the unambiguously matched toplevel index,
    // or -1 if still ambiguous/typing. Clears typedKeys on a successful match.
    function resolveTypedKey(char) {
        root.typedKeys += char;
        console.log('[resolveTypedKey] char:', char, '| typedKeys:', root.typedKeys, '| hotkeys:', JSON.stringify(root.hotkeys.map(h => h.hotkey)));

        let match = root.hotkeys.find(h => h.hotkey === root.typedKeys);
        let ambiguous = root.hotkeys.some(h => h.hotkey !== root.typedKeys && h.hotkey.startsWith(root.typedKeys));
        console.log('[resolveTypedKey] match:', match ? match.hotkey : 'none', '| ambiguous:', ambiguous);

        if (match) {
            const idx = root.allToplevels.indexOf(match.toplevel);
            if (!ambiguous) {
                // Unambiguous: clear typed buffer, fire immediately via timer
                console.log('[resolveTypedKey] unambiguous match -> idx:', idx);
                root.typedKeys = "";
            } else {
                // Ambiguous: an exact match exists but longer hotkeys share this prefix.
                // Return the match so the timer starts; keep typedKeys so the user can
                // still type more characters to land on a longer hotkey instead.
                console.log('[resolveTypedKey] ambiguous exact match -> idx:', idx, '(timer will fire unless overridden)');
            }
            return idx;
        }

        if (!root.hotkeys.some(h => h.hotkey.startsWith(root.typedKeys))) {
            // Nothing at all starts with the accumulated buffer - reset to just this char
            console.log('[resolveTypedKey] no prefix match, resetting to:', char);
            root.typedKeys = char;
            match = root.hotkeys.find(h => h.hotkey === root.typedKeys);
            ambiguous = root.hotkeys.some(h => h.hotkey !== root.typedKeys && h.hotkey.startsWith(root.typedKeys));
            if (match) {
                const idx = root.allToplevels.indexOf(match.toplevel);
                if (!ambiguous) {
                    console.log('[resolveTypedKey] unambiguous match after reset -> idx:', idx);
                    root.typedKeys = "";
                } else {
                    console.log('[resolveTypedKey] ambiguous match after reset -> idx:', idx);
                }
                return idx;
            }
        }

        console.log('[resolveTypedKey] no match, returning -1');
        return -1;
    }


    Themer {
        id: theme
        settingName: 'toplevel'
    }

    onActiveChanged: {
        if (!active) {
            typedKeys = "";
            saveModeActive = false;
            deleteModeActive = false;
            targetToplevel = null;
            hotkeys = hotkeys.filter(h => h.persist);
            activateTimer.stop();
            pendingActivation = null;
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

    Timer {
        id: activateTimer
        interval: 200
        onTriggered: {
            // Save target first — setting active=false triggers onActiveChanged
            // which clears pendingActivation, so we must grab it before that.
            const target = root.pendingActivation;
            console.log('[activateTimer] fired | target:', target?.wayland?.title ?? target?.wayland?.appId ?? 'null');
            root.pendingActivation = null;
            root.active = false;
            if (target) {
                console.log('[activateTimer] activating:', target.wayland?.title ?? target.wayland?.appId);
                target.wayland.activate();
            } else {
                console.log('[activateTimer] fired but target was null, nothing to do');
            }
        }
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

        HyprlandFocusGrab {
            active: root.active
            windows: [toplevelView]
            onCleared: root.active = false
        }

        Rectangle {
            id: offMonitorBar

            visible: Object.keys(root.workspaceGroups).length > 0

            property bool topBar: Settings.get('barPosition').value
            anchors.top: parent.top
            anchors.margins: topBar ? Styles.marginMd * 3 : Styles.marginSm
            anchors.horizontalCenter: parent.horizontalCenter

            width: offMonitorFlow.implicitWidth + Styles.marginSm
            height: offMonitorFlow.implicitHeight + Styles.marginSm

            color: theme.foreground
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
                        color: theme.background
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

                            property var hotkeyEntry: root.hotkeys.find(h => h.toplevel === modelData)
                            property string keyLabel: hotkeyEntry?.hotkey ?? ""
                            property bool isPersisted: hotkeyEntry?.persist ?? false
                            property string matchedPart: root.typedKeys !== "" && keyLabel.startsWith(root.typedKeys) ? root.typedKeys : ""
                            property string unmatchedPart: matchedPart !== "" ? keyLabel.substring(matchedPart.length) : keyLabel

                            defaultColor: isPersisted ? Qt.lighter(theme.background, 1.4) : theme.background

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
                                    color: theme.background
                                    radius: Styles.radiusLg
                                    Row {
                                        id: textRow
                                        anchors.centerIn: parent
                                        TextStyled {
                                            text: offMonitor.matchedPart.toUpperCase()
                                            color: theme.background
                                            font.bold: true
                                            font.pointSize: Styles.textSm
                                        }
                                        TextStyled {
                                            text: offMonitor.unmatchedPart.toUpperCase()
                                            color: theme.text
                                            font.pointSize: Styles.textSm
                                        }
                                    }
                                }
                                TextStyled {
                                    Layout.fillWidth: true
                                    text: root.toplevelLabel(offMonitor.modelData)
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
            color: theme.background
            width: 50
            height: 50
            radius: Styles.radiusMd
            TextFieldStyled {
                id: workspaceInputField
                placeholderText: 'workspace'
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
            model: root.toplevels
            delegate: Rectangle {
                id: onScreen

                required property var modelData
                required property int index

                property var hotkeyEntry: root.hotkeys.find(h => h.toplevel === modelData)
                property string keyLabel: hotkeyEntry?.hotkey ?? ""
                property bool isPersisted: hotkeyEntry?.persist ?? false
                property string matchedPart: root.typedKeys !== "" && keyLabel.startsWith(root.typedKeys) ? root.typedKeys : ""
                property string unmatchedPart: matchedPart !== "" ? keyLabel.substring(matchedPart.length) : keyLabel

                property ClientInfo clientInfo: HyprctlClients.clients.find(client => modelData.address === client.address.replace('0x', ''))
                property var clientMonitor: Hyprland.monitors.values.find(monitor => monitor.id === clientInfo?.monitor)

                width: 80
                height: 60

                x: clientInfo ? clientInfo.at[0] - (clientMonitor?.x ?? 0) + clientInfo.size[0] / 2 - width / 2 : 0
                y: clientInfo ? clientInfo.at[1] - (clientMonitor?.y ?? 0) + clientInfo.size[1] / 2 - height / 2 : 0

                color: {
                    const base = modelData.activated ? theme.background : theme.foreground;
                    return isPersisted ? Qt.lighter(base, 1.4) : base;
                }
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
                                color: theme.background
                                font.bold: true
                                font.pointSize: Styles.textSm
                            }
                            TextStyled {
                                text: onScreen.unmatchedPart.toUpperCase()
                                color: theme.text
                                font.pointSize: Styles.textSm
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: slotsPanel
            visible: root.hotkeys.some(h => h.persist)
            anchors.bottom: saveModeBanner.visible ? saveModeBanner.top : parent.bottom
            anchors.right: parent.right
            anchors.margins: Styles.marginLg * 2
            width: slotsColumn.implicitWidth + Styles.marginSm * 2
            height: slotsColumn.implicitHeight + Styles.marginSm * 2
            color: theme.background
            radius: Styles.radiusMd
        }

        Rectangle {
            id: saveModeBanner
            visible: root.saveModeActive || root.deleteModeActive
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: Styles.marginLg * 2
            width: bannerText.implicitWidth + Styles.marginLg * 2
            height: bannerText.implicitHeight + Styles.marginSm * 2
            color: root.deleteModeActive ? Colors.error : theme.acent
            radius: Styles.radiusMd

            TextStyled {
                id: bannerText
                anchors.centerIn: parent
                text: root.deleteModeActive
                    ? "DELETE MODE: Press a hotkey to remove its alias"
                    : (root.targetToplevel === null
                        ? "SAVE MODE: Press a window key..."
                        : "SAVE MODE: Press an alias key (a-z) to assign to '" + root.toplevelLabel(root.targetToplevel) + "'")
                color: root.deleteModeActive ? Colors.onError : theme.text
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
                    root.deleteModeActive = false;
                    root.targetToplevel = null;
                    root.typedKeys = "";
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Shift) {
                    root.deleteModeActive = !root.deleteModeActive;
                    root.saveModeActive = false;
                    root.targetToplevel = null;
                    root.typedKeys = "";
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Backspace) {
                    root.hotkeys = root.hotkeys.filter(h => !h.persist);
                    root.storedSlots = {};
                    persistentSlots.save({});
                    root.updateToplevels();
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    const enterMatch = root.hotkeys.find(h => h.hotkey === root.typedKeys) ?? (root.pendingActivation ? { toplevel: root.pendingActivation } : null);
                    if (enterMatch) {
                        activateTimer.stop();
                        root.pendingActivation = null;
                        root.active = false;
                        root.typedKeys = "";
                        enterMatch.toplevel.wayland.activate();
                        event.accepted = true;
                        return;
                    }
                }

                if (event.key === Qt.Key_Escape) {
                    if (root.saveModeActive) {
                        root.saveModeActive = false;
                        root.targetToplevel = null;
                    } else if (root.deleteModeActive) {
                        root.deleteModeActive = false;
                    } else {
                        root.active = false;
                    }
                    activateTimer.stop();
                    root.pendingActivation = null;
                    root.typedKeys = "";
                    event.accepted = true;
                    return;
                }

                if (root.deleteModeActive) {
                    const pressedChar = event.text.toLowerCase();
                    if (pressedChar === "" || !/^[a-z]$/.test(pressedChar))
                        return;
                    event.accepted = true;

                    const toDelete = root.hotkeys.find(h => h.hotkey === pressedChar && h.persist);
                    if (toDelete) {
                        root.hotkeys = root.hotkeys.filter(h => !(h.hotkey === pressedChar && h.persist));
                        const newSlots = {};
                        root.hotkeys.filter(h => h.persist).forEach(h => { newSlots[h.hotkey] = h.toplevel.address; });
                        root.storedSlots = newSlots;
                        persistentSlots.save(newSlots);
                        root.updateToplevels();
                    }
                    root.deleteModeActive = false;
                    root.typedKeys = "";
                    return;
                }

                if (root.saveModeActive) {
                    let pressedChar = event.text.toLowerCase();
                    if (pressedChar === "" || !/^[a-z]$/.test(pressedChar))
                        return;
                    event.accepted = true;

                    if (root.targetToplevel === null) {
                        let idx = root.resolveTypedKey(pressedChar);
                        if (idx !== -1)
                            root.targetToplevel = root.allToplevels[idx];
                    } else {
                        root.setHotkey(root.targetToplevel, pressedChar, true);
                        const newSlots = {};
                        root.hotkeys.filter(h => h.persist).forEach(h => { newSlots[h.hotkey] = h.toplevel.address; });
                        root.storedSlots = newSlots;
                        persistentSlots.save(newSlots);
                        root.saveModeActive = false;
                        root.targetToplevel = null;
                        root.typedKeys = "";
                    }
                    return;
                }

                if (event.text.match(/[0-9-+]/) !== null) { // Workspace input
                    workspaceInputField.text = event.text;
                    workspaceInput.visible = true;
                    workspaceInputField.focus = true;
                    return;
                }

                // Select a window by prefix
                let pressedChar = event.text.toLowerCase();
                if (pressedChar === "" || !/^[a-z]$/.test(pressedChar))
                    return;
                event.accepted = true;
                let idx = root.resolveTypedKey(pressedChar);
                console.log('[keyHandler] idx:', idx, '| pendingActivation:', root.pendingActivation?.wayland?.title ?? root.pendingActivation?.wayland?.appId ?? 'null');
                if (idx !== -1) {
                    root.pendingActivation = root.allToplevels[idx];
                    console.log('[keyHandler] set pendingActivation:', root.pendingActivation?.wayland?.title ?? root.pendingActivation?.wayland?.appId);
                    activateTimer.restart();
                } else if (root.pendingActivation !== null) {
                    console.log('[keyHandler] no new match, keeping pendingActivation and resetting timer');
                    activateTimer.restart();
                }
            }
        }
    }
}
