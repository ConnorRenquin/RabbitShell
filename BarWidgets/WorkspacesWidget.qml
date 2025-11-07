import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

import qs.Global
import qs.Constants

BarWidget {
    id: root
    property int margin: 5
    required property string monitorName

    width: row.implicitWidth + 10
    Behavior on width {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutQuad
        }
    }
    Row {
        id: row
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: Hyprland.workspaces.values.filter(workspace => workspace.id != -99 && workspace.monitor?.name == monitorName)
            Rectangle {
                implicitHeight: root.height - (margin * 2)
                implicitWidth: text.width + 25
                radius: modelData.focused ? 15 : 5

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
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch(`workspace ${modelData.id}`);
                    }
                }
            }
        }
    }
}
