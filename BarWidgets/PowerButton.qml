import Quickshell
import Quickshell.Io
import QtQuick

import qs.Global
import qs.Constants

BarWidget {
    id: root
    property bool showMenu: false

    width: parent.height

    TextStyled {
        text: "⏻"
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.showMenu = !root.showMenu;
        }
    }

    function menuAction(commandArray) {
        root.showMenu = false;
        Quickshell.execDetached(commandArray);
    }

    PopupWindow {
        anchor {
            window: root.QsWindow.window
            rect {
                y: root.height + 10
                x: root.x * 20
            }
        }
        visible: root.showMenu
        implicitWidth: 120
        implicitHeight: 180
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Colors.bgDim
            radius: 5

            Column {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                // TODO This is meant to mean the button within the power menu, need to refactor and introduce a generic button.
                PowerMenuButton {
                    label: "Logout"
                    command: "logout"
                    onClicked: root.menuAction(["bash", "-c", "hyprctl dispatch exit"])
                }

                PowerMenuButton {
                    label: "Lock"
                    command: "lock"
                    onClicked: root.menuAction(["hyprlock"])
                }

                PowerMenuButton {
                    label: "Reboot"
                    command: "reboot"
                    onClicked: root.menuAction(["reboot"])
                }

                PowerMenuButton {
                    label: "Shutdown"
                    command: "shutdown"
                    onClicked: root.menuAction(["shutdown"])
                }
            }
        }
    }
}
