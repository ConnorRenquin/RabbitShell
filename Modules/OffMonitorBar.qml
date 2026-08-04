pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

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

    property string typedKeys: ""
    property var pendingActivation: null
    property var workspaceGroups: ({})
    property var toplevels: []
    property var hotkeys: []

    function toplevelLabel(toplevel) {
        const useAppId = Settings.get('toplevelLabel')?.value === 'appId';
        const primary = useAppId ? toplevel?.wayland?.appId : toplevel?.wayland?.title;
        const fallback = useAppId ? toplevel?.wayland?.title : toplevel?.wayland?.appId;
        return controls.preferredLabel(primary, fallback, "Unknown App");
    }

    function updateToplevels() {
        if (!Hyprland.toplevels || !Hyprland.focusedWorkspace)
            return;

        workspaceGroups = Hyprland.toplevels.values.reduce((groups, toplevel) => {
            const workspaceId = toplevel?.workspace?.id;
            if (workspaceId === undefined || workspaceId === null || workspaceId === Hyprland.focusedWorkspace.id)
                return groups;

            if (!groups[workspaceId])
                groups[workspaceId] = [];
            groups[workspaceId].push(toplevel);
            return groups;
        }, {});

        toplevels = Object.keys(workspaceGroups)
            .sort((a, b) => parseInt(a) - parseInt(b))
            .map(workspaceId => workspaceGroups[workspaceId])
            .reduce((items, workspaceToplevels) => items.concat(workspaceToplevels), []);

        const newHotkeys = [];
        for (const toplevel of toplevels) {
            const hotkey = controls.generateHotkey(root.toplevelLabel(toplevel), newHotkeys);
            newHotkeys.push({ toplevel, hotkey });
        }
        hotkeys = newHotkeys;
    }

    function close() {
        activateTimer.stop();
        pendingActivation = null;
        typedKeys = "";
        active = false;
    }

    Controls {
        id: controls
    }

    Component.onCompleted: updateToplevels()

    onActiveChanged: {
        if (!active) {
            typedKeys = "";
            activateTimer.stop();
            pendingActivation = null;
        }
    }

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
        name: "offmonitorbar"
        onPressed: {
            root.updateToplevels();
            hideTimer.restart();
            root.active = true;
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.close()
    }

    Timer {
        id: activateTimer
        interval: 200
        onTriggered: {
            const target = root.pendingActivation;
            root.pendingActivation = null;
            root.active = false;
            if (target)
                target.wayland.activate();
        }
    }

    sourceComponent: PanelWindow {
        id: panel

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.namespace: "off-monitor-bar"
        WlrLayershell.layer: WlrLayer.Overlay

        mask: Region {
            item: bar
        }

        HyprlandFocusGrab {
            active: root.active
            windows: [panel]
            onCleared: root.close()
        }

        Themer {
            id: theme
            settingName: 'toplevel'
        }

        Rectangle {
            id: bar

            anchors.centerIn: parent
            implicitWidth: root.toplevels.length > 0
                ? workspaceGrid.implicitWidth + Styles.marginSm
                : emptyState.implicitWidth
            implicitHeight: root.toplevels.length > 0
                ? workspaceGrid.implicitHeight + Styles.marginSm
                : emptyState.implicitHeight
            color: "transparent"

            Rectangle {
                id: emptyState

                anchors.centerIn: parent
                visible: root.toplevels.length === 0
                implicitWidth: emptyStateText.implicitWidth + Styles.marginSm * 2
                implicitHeight: emptyStateText.implicitHeight + Styles.marginSm * 2
                color: theme.background
                radius: Styles.radiusMd

                TextStyled {
                    id: emptyStateText
                    anchors.centerIn: parent
                    text: "No windows on other workspaces"
                    color: theme.text
                    font.pointSize: Styles.textSm
                }
            }

            GridLayoutPlus {
                id: workspaceGrid

                property var workspaceIds: Object.keys(root.workspaceGroups).sort((a, b) => parseInt(a) - parseInt(b))

                function cardWidth(workspaceId) {
                    const workspaceToplevels = root.workspaceGroups[workspaceId] ?? [];
                    const firstClient = workspaceToplevels.length > 0
                        ? HyprctlClients.clients.find(client => workspaceToplevels[0].address === client.address.replace('0x', ''))
                        : null;
                    const monitor = Hyprland.monitors.values.find(candidate => candidate.id === firstClient?.monitor);
                    return (monitor?.width ?? 1920) / 5 + Styles.marginSm;
                }

                function fittingColumnCount() {
                    const availableWidth = Math.max(0, panel.width - Styles.marginSm * 2);
                    let occupiedWidth = 0;
                    let count = 0;

                    for (const workspaceId of workspaceIds) {
                        const nextWidth = cardWidth(workspaceId) + (count > 0 ? columnSpacing : 0);
                        if (count > 0 && occupiedWidth + nextWidth > availableWidth)
                            break;
                        occupiedWidth += nextWidth;
                        count++;
                    }

                    return Math.max(1, count);
                }

                anchors.centerIn: parent
                visible: root.toplevels.length > 0
                columns: fittingColumnCount()
                columnSpacing: Styles.marginSm
                rowSpacing: Styles.marginSm
                model: workspaceIds

                delegate: Rectangle {
                    id: workspaceBackground

                    required property var modelData
                    property var workspaceToplevels: root.workspaceGroups[modelData] ?? []
                    property var firstClientInfo: workspaceToplevels.length > 0
                        ? HyprctlClients.clients.find(client => workspaceToplevels[0].address === client.address.replace('0x', ''))
                        : null
                    property var monitorInfo: Hyprland.monitors.values.find(monitor => monitor.id === firstClientInfo?.monitor)

                    Layout.alignment: Qt.AlignTop
                    implicitWidth: workspaceColumn.implicitWidth + Styles.marginSm
                    implicitHeight: workspaceColumn.implicitHeight + Styles.marginSm
                    color: "transparent"
                    radius: Styles.radiusMd

                    ColumnLayout {
                        id: workspaceColumn
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        Rectangle {
                            Layout.alignment: Qt.AlignTop
                            Layout.preferredHeight: workspaceId.implicitHeight + Styles.marginSm
                            Layout.preferredWidth: workspaceId.implicitWidth + Styles.marginSm
                            color: theme.foreground
                            radius: Styles.radiusMd

                            TextStyled {
                                id: workspaceId
                                anchors.fill: parent
                                text: "󰜌 " + workspaceBackground.modelData
                                font.pointSize: Styles.textSm
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            id: workspaceCanvas
                            color: theme.background
                            radius: Styles.radiusLg

                            Layout.preferredWidth: (workspaceBackground.monitorInfo?.width ?? 1920) / 5
                            Layout.preferredHeight: (workspaceBackground.monitorInfo?.height ?? 1080) / 5

                            Repeater {
                                model: workspaceBackground.workspaceToplevels

                                delegate: Rectangle {
                                    id: offMonitor

                                    required property var modelData

                                    property var clientInfo: HyprctlClients.clients.find(client => modelData.address === client.address.replace('0x', ''))
                                    property var hotkeyEntry: root.hotkeys.find(entry => entry.toplevel === modelData)
                                    property string keyLabel: hotkeyEntry?.hotkey ?? ""
                                    property string matchedPart: controls.matchedHotkeyPart(root.typedKeys, keyLabel)
                                    property string unmatchedPart: controls.unmatchedHotkeyPart(root.typedKeys, keyLabel)
                                    property real previewScale: 0.2

                                    x: clientInfo ? (clientInfo.at[0] - (workspaceBackground.monitorInfo?.x ?? 0)) * previewScale : 0
                                    y: clientInfo ? (clientInfo.at[1] - (workspaceBackground.monitorInfo?.y ?? 0)) * previewScale : 0
                                    width: clientInfo ? clientInfo.size[0] * previewScale : 0
                                    height: clientInfo ? clientInfo.size[1] * previewScale : 0
                                    color: "transparent"
                                    radius: Styles.radiusSm
                                    clip: true

                                    ScreencopyView {
                                        id: preview
                                        anchors.fill: parent
                                        anchors.margins: Styles.marginSm
                                        captureSource: root.active ? offMonitor.modelData.wayland : null
                                        live: root.active
                                        paintCursor: false
                                    }

                                    IconImage {
                                        anchors.right: preview.right
                                        anchors.bottom: preview.bottom
                                        implicitWidth: 32
                                        implicitHeight: 32
                                        source: Quickshell.iconPath(DesktopEntries.byId(offMonitor.modelData.wayland?.appId)?.icon, "applications-other")
                                    }

                                    Rectangle {
                                        anchors.centerIn: parent
                                        implicitWidth: Math.min(textRow.implicitWidth, offMonitor.width - Styles.marginSm * 2)
                                        implicitHeight: textRow.implicitHeight + Styles.marginSm
                                        color: theme.background
                                        radius: Styles.radiusSm

                                        RowLayout {
                                            id: textRow
                                            anchors.fill: parent
                                            anchors.margins: 4

                                            TextStyled {
                                                text: offMonitor.matchedPart.toUpperCase()
                                                color: theme.foreground
                                                font.bold: true
                                            }

                                            TextStyled {
                                                text: offMonitor.unmatchedPart.toUpperCase()
                                                color: theme.text
                                            }

                                            TextStyled {
                                                text: root.toplevelLabel(offMonitor.modelData)
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                                font.pointSize: Styles.textSm
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            focus: true

            Keys.onPressed: event => {
                hideTimer.restart();

                if (controls.enterPressed(event)) {
                    const match = root.hotkeys.find(entry => entry.hotkey === root.typedKeys)
                        ?? (root.pendingActivation ? { toplevel: root.pendingActivation } : null);
                    if (match) {
                        activateTimer.stop();
                        root.pendingActivation = null;
                        root.typedKeys = "";
                        root.active = false;
                        match.toplevel.wayland.activate();
                        event.accepted = true;
                    }
                    return;
                }

                if (controls.escapePressed(event)) {
                    root.close();
                    event.accepted = true;
                    return;
                }

                const pressedCharacter = event.text.toLowerCase();
                if (pressedCharacter === "" || !/^[a-z]$/.test(pressedCharacter))
                    return;

                event.accepted = true;
                const result = controls.resolveTypedHotkey(pressedCharacter, root.typedKeys, root.hotkeys, root.toplevels);
                root.typedKeys = result.typedKeys;
                if (result.index !== -1) {
                    root.pendingActivation = root.toplevels[result.index];
                    activateTimer.restart();
                } else if (root.pendingActivation !== null) {
                    activateTimer.restart();
                }
            }
        }
    }
}
