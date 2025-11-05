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

    PanelWindow {
        visible: root.showMenu
        implicitWidth: 120
        implicitHeight: 180
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

                // TODO This is meant to mean the button within the power menu, need to refactor and introduce a generic button.
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
