import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Row {
    spacing: 10

    Repeater {
        model: Hyprland.workspaces.values.filter(workspace => workspace.id != -99)
        Rectangle {
            property string backgroundColor: modelData.focused ? Colors.fg : Colors.bgDim
            property string textColor: modelData.focused ? Colors.bgDim : Colors.fg
            implicitHeight: Constants.widgetHeight

            implicitWidth: 30
            radius: 5
            color: backgroundColor
            TextStyled {
                text: modelData.id
                anchors.centerIn: parent
                color: textColor
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
