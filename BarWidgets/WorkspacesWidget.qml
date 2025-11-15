import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

import qs.Components
import qs.Constants

BarWidget {
    id: root
    property int margin: Styles.margin
    required property string monitorName

    width: row.implicitWidth + Styles.margin

    Behavior on width {
        NumberAnimation {
            duration: 150
        }
    }

    Row {
        id: row
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: Styles.marginSm / 2
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: Hyprland.workspaces.values.filter(workspace => workspace.id != -99 && workspace.monitor?.name == monitorName)
            Rectangle {
                implicitHeight: root.height - Styles.marginSm
                implicitWidth: text.implicitWidth + Styles.marginSm
                radius: modelData.focused ? Styles.radiusLg : Styles.radiusSm
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
                    anchors.centerIn: parent
                    text: modelData.focused ? "󰜋" : "󰜌"
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
