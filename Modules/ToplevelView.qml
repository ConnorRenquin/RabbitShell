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
import qs.Components.Plus
import qs.Components.Styled
import qs.Services
import qs.Services.Models

Loader {
    id: root

    active: false

    property string typedKeys: ""
    property var pendingActivation: null
    property var toplevels: []
    property var workspaceGroups: []
    property var allToplevels: []
    property var hotkeys: []


    // assigned: array of already-committed {hotkey} entries to check against.
    // Passing it explicitly avoids relying on root.hotkeys mid-update.
    function generateHotkey(toplevel, assigned) {
        const useAppId = Settings.get('toplevelLabel')?.value === 'appId';
        const raw = useAppId
            ? (toplevel?.wayland?.appId || toplevel?.wayland?.title || "unknown")
            : (toplevel?.wayland?.title || toplevel?.wayland?.appId || "unknown");
        const name = raw.toLowerCase().replace(/[^a-z]/g, '') || "unknown";

        const taken = key => assigned.some(h => h.hotkey === key);

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


        // Build into a local array so conflict checks use a consistent snapshot.
        const newHotkeys = [];
        for (const toplevel of allToplevels) {
            const hotkey = generateHotkey(toplevel, newHotkeys);
            newHotkeys.push({ toplevel, hotkey });
        }

        hotkeys = newHotkeys;
    }

    // Appends char to typedKeys and returns the unambiguously matched toplevel index,
    // or -1 if still ambiguous/typing. Clears typedKeys on a successful match.
    function resolveTypedKey(char) {
        root.typedKeys += char;

        let match = root.hotkeys.find(h => h.hotkey === root.typedKeys);
        let ambiguous = root.hotkeys.some(h => h.hotkey !== root.typedKeys && h.hotkey.startsWith(root.typedKeys));

        if (match) {
            const idx = root.allToplevels.indexOf(match.toplevel);
            if (!ambiguous) {
                // Unambiguous: clear typed buffer, fire immediately via timer
                root.typedKeys = "";
            }
            return idx;
        }

        if (!root.hotkeys.some(h => h.hotkey.startsWith(root.typedKeys))) {
            // Nothing at all starts with the accumulated buffer - reset to just this char
            root.typedKeys = char;
            match = root.hotkeys.find(h => h.hotkey === root.typedKeys);
            ambiguous = root.hotkeys.some(h => h.hotkey !== root.typedKeys && h.hotkey.startsWith(root.typedKeys));
            if (match) {
                const idx = root.allToplevels.indexOf(match.toplevel);
                if (!ambiguous)
                    root.typedKeys = "";
                return idx;
            }
        }

        return -1;
    }


    Themer {
        id: theme
        settingName: 'toplevel'
    }

    onActiveChanged: {
        if (!active) {
            typedKeys = "";
            activateTimer.stop();
            pendingActivation = null;
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
            root.pendingActivation = null;
            root.active = false;
            if (target)
                target.wayland.activate();
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

                            implicitWidth: 175
                            implicitHeight: 50
                            isFocused: modelData.activated

                            onClicked: modelData.wayland.activate()

                            property var hotkeyEntry: root.hotkeys.find(h => h.toplevel === modelData)
                            property string keyLabel: hotkeyEntry?.hotkey ?? ""
                            property string matchedPart: root.typedKeys !== "" && keyLabel.startsWith(root.typedKeys) ? root.typedKeys : ""
                            property string unmatchedPart: matchedPart !== "" ? keyLabel.substring(matchedPart.length) : keyLabel

                            defaultColor: theme.background

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Styles.marginSm
                                Rectangle {
                                    Layout.preferredWidth: 64
                                    Layout.fillHeight: true
                                    radius: Styles.radiusSm
                                    color: theme.foreground
                                    clip: true

                                    ScreencopyView {
                                        id: preview
                                        anchors.fill: parent
                                        captureSource: root.active ? offMonitor.modelData.wayland : null
                                        live: root.active
                                        paintCursor: false
                                    }
                                }
                                IconImage {
                                    Layout.preferredHeight: 28
                                    Layout.preferredWidth: 28
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

        Repeater {
            model: root.toplevels
            delegate: Rectangle {
                id: onScreen

                required property var modelData

                property var hotkeyEntry: root.hotkeys.find(h => h.toplevel === modelData)
                property string keyLabel: hotkeyEntry?.hotkey ?? ""
                property string matchedPart: root.typedKeys !== "" && keyLabel.startsWith(root.typedKeys) ? root.typedKeys : ""
                property string unmatchedPart: matchedPart !== "" ? keyLabel.substring(matchedPart.length) : keyLabel

                property ClientInfo clientInfo: HyprctlClients.clients.find(client => modelData.address === client.address.replace('0x', ''))
                property var clientMonitor: Hyprland.monitors.values.find(monitor => monitor.id === clientInfo?.monitor)

                width: 80
                height: 60

                x: clientInfo ? clientInfo.at[0] - (clientMonitor?.x ?? 0) + clientInfo.size[0] / 2 - width / 2 : 0
                y: clientInfo ? clientInfo.at[1] - (clientMonitor?.y ?? 0) + clientInfo.size[1] / 2 - height / 2 : 0

                color: modelData.activated ? theme.background : theme.foreground
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
            id: controller

            anchors.fill: parent
            color: "transparent"
            focus: true

            Keys.onPressed: function (event) {
                hideTimer.restart();

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
                    root.active = false;
                    activateTimer.stop();
                    root.pendingActivation = null;
                    root.typedKeys = "";
                    event.accepted = true;
                    return;
                }

                let pressedChar = event.text.toLowerCase();
                if (pressedChar === "" || !/^[a-z]$/.test(pressedChar))
                    return;
                event.accepted = true;
                let idx = root.resolveTypedKey(pressedChar);
                if (idx !== -1) {
                    root.pendingActivation = root.allToplevels[idx];
                    activateTimer.restart();
                } else if (root.pendingActivation !== null) {
                    activateTimer.restart();
                }
            }
        }
    }
}
