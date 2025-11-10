import Quickshell
import QtQuick
import Quickshell.Hyprland

import qs.Components
import qs.Constants

BarWidget {
    id: root
    property bool showMenu: false
    property int currentFocusIndex: 0

    width: parent.height

    onShowMenuChanged: {
        if (showMenu) {
            currentFocusIndex = 0;
            updateButtonFocus();
        }
    }

    function updateButtonFocus() {
        for (var i = 0; i < buttons.children.length; i++) {
            buttons.children[i].isFocused = (i === currentFocusIndex);
        }
    }

    function executeCurrentItem() {
        if (currentFocusIndex >= 0 && currentFocusIndex < buttons.children.length) {
            buttons.children[currentFocusIndex].clicked();
        }
    }

    GlobalShortcut {
        name: "powermenu"
        onPressed: {
            root.showMenu = !root.showMenu;
        }
    }

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
        id: popupWindow
        anchor {
            item: root
            rect {
                x: root.x
                y: root.height + 10
            }
        }
        visible: root.showMenu
        implicitWidth: menuBackground.implicitWidth
        implicitHeight: menuBackground.implicitHeight
        color: "transparent"

        HyprlandFocusGrab {
            active: popupWindow.visible
            windows: [popupWindow]
        }

        Rectangle {
            id: menuBackground
            color: Colors.bgDim
            radius: 10
            implicitWidth: 220
            implicitHeight: buttons.implicitHeight + 10
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.showMenu = false;
                    event.accepted = true;
                } else if (event.key === Qt.Key_J || event.key === Qt.Key_Down) {
                    currentFocusIndex = Math.min(currentFocusIndex + 1, buttons.children.length - 1);
                    updateButtonFocus();
                    event.accepted = true;
                } else if (event.key === Qt.Key_K || event.key === Qt.Key_Up) {
                    currentFocusIndex = Math.max(currentFocusIndex - 1, 0);
                    updateButtonFocus();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    executeCurrentItem();
                    event.accepted = true;
                }
            }

            Column {
                id: buttons
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

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
