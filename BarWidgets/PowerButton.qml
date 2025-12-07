import Quickshell
import QtQuick
import Quickshell.Hyprland

import qs.Components
import qs.Constants

ButtonWidget {
    id: root
    icon: "⏻"

    GlobalShortcut {
        name: "powermenu"
        onPressed: {
            popupWindow.visible = !popupWindow.visible;
            grab.active = true;
        }
    }

    onClicked: popupWindow.visible = !popupWindow.visible

    property int currentFocusIndex: 0

    function executeCurrentItem() {
        if (currentFocusIndex >= 0 && currentFocusIndex < buttons.children.length) {
            buttons.children[currentFocusIndex].clicked(null);
        }
    }

    function menuAction(command) {
        popupWindow.visible = false;
        Quickshell.execDetached(["bash", "-c", command]);
    }

    component PowerMenuButton: ButtonStyled {
        id: menuButton

        radius: Styles.radius0
        height: text.implicitHeight + 20
        implicitWidth: parent.width

        property string label: ""

        defaultColor: Colors.bg0
        hoverColor: Colors.bgGreen
        focusedColor: Colors.orange

        isFocused: index === currentFocusIndex

        TextStyled {
            id: text
            anchors.centerIn: parent
            text: isFocused || containsMouse ? "> " + menuButton.label : menuButton.label
            color: Colors.yellow
        }
    }

    // Menu
    PopupWindow {
        id: popupWindow

        implicitWidth: menuBackground.implicitWidth
        implicitHeight: menuBackground.implicitHeight

        color: "transparent"

        anchor {
            item: root
            rect {
                x: root.x
                y: root.height + 10
            }
        }

        HyprlandFocusGrab {
            id: grab
            windows: [popupWindow]
            onCleared: popupWindow.visible = false
        }

        Rectangle {
            id: menuBackground
            color: Colors.bgRed
            radius: Styles.margin
            implicitWidth: 220
            implicitHeight: buttons.implicitHeight + Styles.marginSm * 2
            focus: true

            Keys.onPressed: event => {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    root.showMenu = false;
                } else if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                    currentFocusIndex = Math.min(currentFocusIndex + 1, buttons.children.length - 1);
                } else if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                    currentFocusIndex = Math.max(currentFocusIndex - 1, 0);
                } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                    executeCurrentItem();
                }
            }

            Column {
                id: buttons

                spacing: Styles.marginSm

                anchors.fill: parent
                anchors.margins: Styles.marginSm

                PowerMenuButton {
                    label: "Logout"
                    onClicked: root.menuAction("hyprctl dispatch exit")
                    property int index: 0
                }

                PowerMenuButton {
                    label: "Lock"
                    onClicked: root.menuAction("hyprlock")
                    property int index: 1
                }

                PowerMenuButton {
                    label: "Sleep"
                    onClicked: root.menuAction("systemctl suspend")
                    property int index: 2
                }

                PowerMenuButton {
                    label: "Reboot"
                    onClicked: root.menuAction("reboot")
                    property int index: 3
                }

                PowerMenuButton {
                    label: "Shutdown"
                    onClicked: root.menuAction("shutdown")
                    property int index: 4
                }
            }
        }
    }
}
