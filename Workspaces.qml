import Quickshell
import Quickshell.Hyprland
import QtQuick

import qs.Constants
import qs.Components

PanelWindow {
    id: root

    visible: false

    implicitWidth: 1000
    implicitHeight: gridView.contentHeight + 20
    anchors.top: true
    margins.top: 80
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    GlobalShortcut {
        name: "workspaces"
        onPressed: {
            root.visible = !root.visible;
        }
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: Colors.bgGreen
        radius: Styles.radiusSm
        focus: true

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                root.visible = false;
                return;
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
            anchors.margins: 10
            height: contentHeight

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
                Rectangle {
                    id: gridItem
                    width: parent.width - Styles.margin
                    height: parent.height - Styles.margin
                    anchors.centerIn: parent
                    radius: modelData.focused ? 15 : Styles.radiusSm // 15 is about the max you can go, not sure why

                    color: modelData.focused ? Colors.green : Colors.bg0

                    Behavior on color {
                        ColorAnimation {
                            duration: 400
                        }
                    }

                    Behavior on radius {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutQuad
                        }
                    }

                    TextStyled {
                        id: text
                        text: modelData.focused ? "󰜋 " + modelData.id : "󰜌 " + modelData.id
                        anchors.centerIn: parent
                        color: modelData.focused ? Colors.bgRed : Colors.fg
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            modelData.activate();
                            root.visible = !root.visible;
                        }
                    }
                }
            }
        }
    }
}
