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
            if (root.toplevels.length === 0)
                return;
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
            implicitWidth: workspaceColumns.implicitWidth + Styles.marginSm
            implicitHeight: workspaceColumns.implicitHeight + Styles.marginSm
            color: "transparent"

            RowLayoutPlus {
                id: workspaceColumns
                anchors.centerIn: parent
                model: Object.keys(root.workspaceGroups).sort((a, b) => parseInt(a) - parseInt(b))

                delegate: Rectangle {
                    id: workspaceBackground

                    required property var modelData
                    property var workspaceToplevels: root.workspaceGroups[modelData] ?? []

                    Layout.alignment: Qt.AlignTop
                    implicitWidth: workspaceColumn.implicitWidth + Styles.marginSm * 2
                    implicitHeight: workspaceColumn.implicitHeight + Styles.marginSm * 2
                    color: theme.background
                    radius: Styles.radiusMd

                    ColumnLayout {
                        id: workspaceColumn
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        Rectangle {
                            Layout.preferredHeight: workspaceId.implicitHeight + Styles.marginSm
                            Layout.fillWidth: true
                            color: theme.background
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

                        ColumnLayoutPlus {
                            model: workspaceBackground.workspaceToplevels

                            delegate: Rectangle {
                                id: offMonitor

                                required property var modelData

                                property var hotkeyEntry: root.hotkeys.find(entry => entry.toplevel === modelData)
                                property string keyLabel: hotkeyEntry?.hotkey ?? ""
                                property string matchedPart: controls.matchedHotkeyPart(root.typedKeys, keyLabel)
                                property string unmatchedPart: controls.unmatchedHotkeyPart(root.typedKeys, keyLabel)

                                Layout.preferredWidth: preview.sourceSize.width / 5
                                Layout.preferredHeight: preview.sourceSize.height / 4.5
                                color: theme.background
                                radius: Styles.radiusSm

                                Item {
                                    anchors.fill: parent
                                    anchors.margins: Styles.marginSm

                                    ScreencopyView {
                                        id: preview
                                        anchors.fill: parent
                                        captureSource: root.active ? offMonitor.modelData.wayland : null
                                        live: root.active
                                        paintCursor: false
                                    }

                                    IconImage {
                                        anchors.right: preview.right
                                        anchors.bottom: preview.bottom
                                        anchors.margins: -15
                                        implicitWidth: 64
                                        implicitHeight: 64
                                        source: Quickshell.iconPath(DesktopEntries.byId(offMonitor.modelData.wayland?.appId)?.icon, "applications-other")
                                    }

                                    Rectangle {
                                        anchors.centerIn: parent
                                        implicitWidth: Math.min(textRow.implicitWidth, preview.sourceSize.width / 6) + Styles.marginSm
                                        height: 45
                                        color: theme.background
                                        radius: Styles.radiusSm

                                        RowLayout {
                                            id: textRow
                                            anchors.fill: parent
                                            anchors.margins: 3

                                            TextStyled {
                                                text: offMonitor.matchedPart.toUpperCase()
                                                color: theme.background
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
