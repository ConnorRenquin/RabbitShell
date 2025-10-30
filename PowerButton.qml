import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: root
    height: Constants.widgetHeight
    width: Constants.widgetHeight
    radius: 5
    color: Colors.bgDim
    property bool showMenu: false

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.showMenu = !root.showMenu;
        }
    }

    PanelWindow {
        visible: root.showMenu
        width: 120
        height: 180
        color: "transparent"
        anchors {
            top: parent.bottom
            right: parent.right
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.bgDim
            radius: 5

            Column {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                PowerMenuButton {
                    label: "Logout"
                    command: "logout"
                    onClicked: root.showMenu = false
                }

                PowerMenuButton {
                    label: "Lock"
                    command: "lock"
                    onClicked: root.showMenu = false
                }

                PowerMenuButton {
                    label: "Reboot"
                    command: "reboot"
                    onClicked: root.showMenu = false
                }

                PowerMenuButton {
                    label: "Shutdown"
                    command: "shutdown"
                    onClicked: root.showMenu = false
                }
            }
        }
    }
}
