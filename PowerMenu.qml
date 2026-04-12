pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Loader {
    id: loader

    active: false

    property int currentFocusIndex: 0

    function toggle() {
        loader.active = !loader.active;
    }

    function menuAction(command) {
        loader.active = false;
        Quickshell.execDetached(["sh", "-c", command]);
    }

    Component.onCompleted: PatchBay.openPowerMenu.connect(toggle)

    GlobalShortcut {
        name: "powermenu"
        onPressed: loader.toggle()
    }

    sourceComponent: PanelWindow {
        id: root

        anchors.top: true
        margins.top: Styles.marginMd * 3
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: menuBackground.implicitWidth
        implicitHeight: menuBackground.implicitHeight
        color: "transparent"

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        component PowerMenuButton: ButtonStyled {
            id: menuButton
            required property int index
            Layout.fillWidth: true
            isFocused: index === loader.currentFocusIndex
        }

        Rectangle {
            id: menuBackground
            color: Colors.background
            radius: Styles.marginSm
            implicitHeight: 70
            implicitWidth: buttons.implicitWidth + Styles.marginSm * 2
            focus: true

            Keys.onPressed: event => {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    loader.active = false;
                } else if ([Qt.Key_Right, Qt.Key_L].includes(event.key)) {
                    loader.currentFocusIndex = Math.min(loader.currentFocusIndex + 1, buttons.children.length - 1);
                } else if ([Qt.Key_Left, Qt.Key_H].includes(event.key)) {
                    loader.currentFocusIndex = Math.max(loader.currentFocusIndex - 1, 0);
                } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                    if (loader.currentFocusIndex >= 0 && loader.currentFocusIndex < buttons.children.length) {
                        buttons.children[loader.currentFocusIndex].clicked(null);
                    }
                }
            }

            RowLayout {
                id: buttons
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                PowerMenuButton {
                    text: "󰿅"
                    onClicked: loader.menuAction("hyprctl dispatch exit")
                    index: 0
                }
                PowerMenuButton {
                    text: ""
                    onClicked: PatchBay.lockScreen()
                    index: 1
                }
                PowerMenuButton {
                    text: "󰤄"
                    onClicked: loader.menuAction("hyprctl dispatch global quickshell:lockscreen && systemctl suspend")
                    index: 2
                }

                PowerMenuButton {
                    text: ""
                    onClicked: loader.menuAction("systemctl reboot || loginctl reboot")
                    index: 3
                }

                PowerMenuButton {
                    text: ""
                    onClicked: loader.menuAction("systemctl poweroff || loginctl poweroff")
                    index: 4
                }

                PowerMenuButton {
                    text: ""
                    onClicked: loader.menuAction("systemctl reboot --firmware-setup || loginctl reboot --firmware-setup")
                    index: 5
                }
            }
        }
    }
}
