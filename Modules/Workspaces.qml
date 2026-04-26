pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick

import qs.Settings
import qs.Components

Loader {
    id: loader
    active: false

    GlobalShortcut {
        name: "workspaces"
        onPressed: active = !active
    }

    sourceComponent: PanelWindow {
        id: root

        property int columns: 5
        implicitWidth: workspaceGrid.count > columns ? workspaceGrid.cellWidth * columns : workspaceGrid.cellWidth * workspaceGrid.count
        implicitHeight: workspaceGrid.cellHeight * Math.ceil(workspaceGrid.count / columns)

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        anchors.top: true
        margins.top: Styles.marginLg * 2

        property string keyMap: "wertyuiopasdfghjklzxcvbnm"
        property var workspaces: Hyprland.workspaces.values.filter(workspace => workspace.id > 0)

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        Rectangle {
            id: base

            color: Colors.surface
            radius: Styles.radiusSm
            focus: true

            anchors.fill: parent

            Keys.onPressed: function (event) {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    loader.active = false;
                }

                var pressedChar = event.text.toLowerCase();
                if (pressedChar === "")
                    return;
                var index = root.keyMap.indexOf(pressedChar);

                var workspace = root.workspaces[index];
                if (workspace.focused) {
                    loader.active = false;
                    event.accepted = true;
                } else {
                    workspace.activate();
                }
            }

            GridView {
                id: workspaceGrid

                anchors.fill: parent
                cellHeight: 100
                cellWidth: 200

                model: root.workspaces
                delegate: Item {
                    id: wrapper
                    required property HyprlandWorkspace modelData
                    required property int index
                    width: workspaceGrid.cellWidth
                    height: workspaceGrid.cellHeight
                    ButtonStyled {
                        id: workspace

                        implicitWidth: workspaceGrid.cellWidth - Styles.marginSm
                        implicitHeight: workspaceGrid.cellHeight - Styles.marginSm

                        radius: wrapper.modelData.focused ? Styles.radiusLg : Styles.radiusSm // 15 is about the max you can go, not sure why

                        clip: true

                        isFocused: wrapper.modelData.focused

                        anchors.centerIn: parent

                        NumberAnimation on radius {
                            duration: 400
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: Styles.marginSm
                            DoubleText {
                                id: text
                                text: wrapper.modelData.focused ? "󰜋 " + key : "󰜌 " + key
                                anchors.horizontalCenter: parent.horizontalCenter
                                pointSize: 26
                                offset: 3
                                elide: Text.ElideNone
                                property string key: root.keyMap[wrapper.index].toUpperCase()
                            }
                            RowLayoutPlus {
                                id: iconRow
                                model: wrapper.modelData.toplevels.values.slice(0, 5) // Setting the max icons here so it doesn't overun.
                                delegate: IconImage {
                                    required property var modelData
                                    height: 32
                                    width: 32
                                    source: {
                                        var source = Quickshell.iconPath(DesktopEntries.byId(modelData.wayland?.appId)?.icon, "applications-other");
                                        return source;
                                    }
                                }
                            }
                        }

                        onClicked: {
                            wrapper.modelData.activate();
                            loader.active = false;
                        }
                    }
                }
            }
        }
    }
}
