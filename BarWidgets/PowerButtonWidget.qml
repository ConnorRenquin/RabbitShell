pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

ButtonStyled {
    id: root

    implicitWidth: parent.height
    text: "⏻"

    GlobalShortcut {
        name: "powermenu"
        onPressed: {
            dropdown.visible = !dropdown.visible;
            grab.active = dropdown.visible;
        }
    }

    onClicked: {
        dropdown.visible = !dropdown.visible;
        grab.active = dropdown.visible;
    }

    property int currentFocusIndex: 0

    function executeCurrentItem() {
        if (currentFocusIndex >= 0 && currentFocusIndex < buttons.children.length) {
            buttons.children[currentFocusIndex].clicked(null);
        }
    }

    function menuAction(command) {
        dropdown.visible = false;
        Quickshell.execDetached(["bash", "-c", command]);
    }

    component PowerMenuButton: ButtonStyled {
        id: menuButton

        required property int index
        required property string label

        implicitHeight: text.implicitHeight + Styles.marginMd
        implicitWidth: parent.width

        isFocused: index === root.currentFocusIndex

        TextStyled {
            id: text
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            font.pixelSize: Styles.textSm
            text: menuButton.isFocused || menuButton.containsMouse ? menuButton.label : menuButton.label
        }
    }

    PopupWindow {
        id: dropdown

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
            windows: [dropdown]
            onCleared: dropdown.visible = false
        }

        Rectangle {
            id: menuBackground
            color: Colors.background
            radius: Styles.marginSm
            implicitWidth: 220
            implicitHeight: buttons.implicitHeight + Styles.marginSm * 2
            focus: true

            Keys.onPressed: event => {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    dropdown.visible = false;
                    grab.active = false;
                } else if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                    root.currentFocusIndex = Math.min(root.currentFocusIndex + 1, buttons.children.length - 1);
                } else if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                    root.currentFocusIndex = Math.max(root.currentFocusIndex - 1, 0);
                } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                    root.executeCurrentItem();
                }
            }

            ColumnLayout {
                id: buttons

                spacing: Styles.marginSm

                anchors.fill: parent
                anchors.margins: Styles.marginSm

                PowerMenuButton {
                    label: "Logout"
                    onClicked: root.menuAction("hyprctl dispatch exit")
                    index: 0
                }

                PowerMenuButton {
                    label: "Lock"
                    onClicked: PatchBay.lockScreen()
                    index: 1
                }

                PowerMenuButton {
                    label: "Sleep"
                    onClicked: root.menuAction("hyprctl dispatch global quickshell:lockscreen && systemctl suspend")
                    index: 2
                }

                PowerMenuButton {
                    label: "Reboot"
                    onClicked: root.menuAction("reboot")
                    index: 3
                }

                PowerMenuButton {
                    label: "Shutdown"
                    onClicked: root.menuAction("shutdown")
                    index: 4
                }
            }
        }
    }
}
