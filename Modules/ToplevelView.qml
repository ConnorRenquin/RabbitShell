pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Helpers
import qs.Components.Plus
import qs.Components.Styled
import qs.Services
import qs.Services.Models

Loader {
    id: root

    active: false

    property bool popupsVisible: false
    property string typedKeys: ""
    property var pendingActivation: null
    property var toplevels: []
    property var allToplevels: []
    property var hotkeys: []


    function toplevelLabel(toplevel) {
        const useAppId = Settings.get('toplevelLabel')?.value === 'appId';
        const primary = useAppId ? toplevel?.wayland?.appId : toplevel?.wayland?.title;
        const fallback = useAppId ? toplevel?.wayland?.title : toplevel?.wayland?.appId;
        return controls.preferredLabel(primary, fallback, "Unknown App");
    }

    function open() {
        closeTimer.stop();
        updateToplevels();
        if (!active)
            active = true;
        Qt.callLater(() => popupsVisible = true);
    }

    function close() {
        if (!popupsVisible && closeTimer.running)
            return;
        popupsVisible = false;
        typedKeys = "";
        activateTimer.stop();
        pendingActivation = null;
        closeTimer.restart();
    }

    function monitorForScreen(screenName) {
        return Hyprland.monitors?.values.find(monitor => monitor.name === screenName) ?? null;
    }

    function toplevelsForScreen(screenName) {
        const monitor = monitorForScreen(screenName);
        const workspaceId = monitor?.activeWorkspace?.id;
        if (workspaceId === undefined || workspaceId === null)
            return [];
        return toplevels.filter(toplevel => toplevel?.workspace?.id === workspaceId);
    }

    function updateToplevels() {
        if (!Hyprland.toplevels || !Hyprland.monitors)
            return;

        const activeWorkspaceIds = Hyprland.monitors.values
            .map(monitor => monitor.activeWorkspace?.id)
            .filter(workspaceId => workspaceId !== undefined && workspaceId !== null);

        toplevels = Hyprland.toplevels.values.filter(toplevel => activeWorkspaceIds.includes(toplevel?.workspace?.id));
        allToplevels = toplevels;

        // Build into a local array so conflict checks use a consistent snapshot.
        const newHotkeys = [];
        for (const toplevel of allToplevels) {
            const hotkey = controls.generateHotkey(root.toplevelLabel(toplevel), newHotkeys);
            newHotkeys.push({ toplevel, hotkey });
        }

        hotkeys = newHotkeys;
    }

    Themer {
        id: theme
        settingName: 'toplevel'
    }

    Controls {
        id: controls
    }

    HyprlandFocusGrab {
        active: root.popupsVisible
        windows: root.item?.instances ?? []
        onCleared: root.close()
    }

    onActiveChanged: {
        if (!active)
            popupsVisible = false;
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

    Connections {
        target: Hyprland.monitors
        function onValuesChanged() {
            root.updateToplevels();
        }
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            root.updateToplevels();
        }
    }

    GlobalShortcut {
        name: "toplevelview"
        onPressed: {
            hideTimer.restart();
            root.open();
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.close()
    }

    Timer {
        id: closeTimer
        interval: 160
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
            root.close();
            if (target)
                target.wayland.activate();
        }
    }

    sourceComponent: Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: toplevelView

            required property var modelData
            property var screenToplevels: root.toplevelsForScreen(modelData.name)

            screen: modelData
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            WlrLayershell.namespace: "toplevels"
            WlrLayershell.layer: WlrLayer.Overlay





            Repeater {
                model: toplevelView.screenToplevels
                delegate: Rectangle {
                    id: onScreen

                    required property var modelData

                    property var hotkeyEntry: root.hotkeys.find(h => h.toplevel === modelData)
                    property string keyLabel: hotkeyEntry?.hotkey ?? ""
                    property string matchedPart: controls.matchedHotkeyPart(root.typedKeys, keyLabel)
                    property string unmatchedPart: controls.unmatchedHotkeyPart(root.typedKeys, keyLabel)

                    property ClientInfo clientInfo: HyprctlClients.clients.find(client => modelData.address === client.address.replace('0x', ''))
                    property var clientMonitor: Hyprland.monitors.values.find(monitor => monitor.id === clientInfo?.monitor)

                    width: 80
                    height: 60

                    x: clientInfo ? clientInfo.at[0] - (clientMonitor?.x ?? 0) + clientInfo.size[0] / 2 - width / 2 : 0
                    y: clientInfo ? clientInfo.at[1] - (clientMonitor?.y ?? 0) + clientInfo.size[1] / 2 - height / 2 : 0

                    color: modelData.activated ? theme.background : theme.foreground
                    radius: Styles.radiusMd
                    scale: root.popupsVisible ? 1 : 0.65
                    opacity: root.popupsVisible ? 1 : 0

                    Behavior on scale {
                        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

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

                    if (controls.enterPressed(event)) {
                        const enterMatch = root.hotkeys.find(h => h.hotkey === root.typedKeys) ?? (root.pendingActivation ? { toplevel: root.pendingActivation } : null);
                        if (enterMatch) {
                            activateTimer.stop();
                            root.pendingActivation = null;
                            root.close();
                            enterMatch.toplevel.wayland.activate();
                            event.accepted = true;
                            return;
                        }
                    }

                    if (controls.escapePressed(event)) {
                        root.close();
                        event.accepted = true;
                        return;
                    }

                    let pressedChar = event.text.toLowerCase();
                    if (pressedChar === "" || !/^[a-z]$/.test(pressedChar))
                        return;
                    event.accepted = true;
                    const result = controls.resolveTypedHotkey(pressedChar, root.typedKeys, root.hotkeys, root.allToplevels);
                    root.typedKeys = result.typedKeys;
                    if (result.index !== -1) {
                        root.pendingActivation = root.allToplevels[result.index];
                        activateTimer.restart();
                    } else if (root.pendingActivation !== null) {
                        activateTimer.restart();
                    }
                }
            }
    }
}
}
