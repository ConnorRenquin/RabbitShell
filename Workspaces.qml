import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick

import qs.Constants
import qs.Components

PanelWindow {
    id: root

    visible: false

    implicitWidth: 1000
    implicitHeight: gridView.contentHeight + Styles.marginSm * 2
    anchors.top: true
    margins.top: 80
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    GlobalShortcut {
        name: "workspaces"
        onPressed: root.visible = !root.visible
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: Colors.bgGreen
        radius: Styles.radiusLg
        focus: true

        Keys.onPressed: function (event) {
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.visible = false;
            }
            var workspaceId = parseInt(event.text);
            if (isNaN(workspaceId))
                return;
            for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                if (Hyprland.workspaces.values[i].id === workspaceId) {
                    Hyprland.workspaces.values[i].activate();
                    break;
                }
            }
        }

        GridView {
            id: gridView

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Styles.marginSm

            cellHeight: 125
            cellWidth: width / Math.min(Hyprland.workspaces.values.filter(workspace => workspace.id > 0).length, 4)

            model: Hyprland.workspaces.values.filter(workspace => workspace.id > 0)

            HyprlandFocusGrab {
                active: root.visible
                windows: [root]
            }

            delegate: Item {
                width: gridView.cellWidth
                height: gridView.cellHeight
                ButtonStyled {
                    id: gridItem
                    anchors.centerIn: parent

                    width: parent.width - Styles.marginSm
                    height: parent.height
                    radius: modelData.focused ? 15 : Styles.radiusSm // 15 is about the max you can go, not sure why

                    isFocused: modelData.focused

                    Behavior on radius {
                        NumberAnimation {
                            duration: 400
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: Styles.marginSm
                        DoubleText {
                            id: text
                            text: modelData.focused ? "󰜋 " + modelData.id : "󰜌 " + modelData.id
                            anchors.horizontalCenter: parent.horizontalCenter
                            pixelSize: 30
                            offset: 3
                            elide: Text.ElideNone
                        }
                        Row {
                            spacing: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            Repeater {
                                model: modelData.toplevels
                                delegate: IconImage {
                                    height: 40
                                    width: 40
                                    source: Quickshell.iconPath(DesktopEntries.byId(modelData.wayland.appId).icon)
                                }
                            }
                        }
                    }

                    onClicked: {
                        modelData.activate();
                        root.visible = !root.visible;
                    }
                }
            }
        }
    }
}
