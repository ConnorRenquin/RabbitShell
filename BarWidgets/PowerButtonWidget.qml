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

    implicitHeight: parent.height
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
        Layout.fillWidth: true
        isFocused: index === root.currentFocusIndex
    }

    PanelWindow {
        id: dropdown

        anchors.top: true
        margins {
            top: Styles.marginMd * 3
        }
        exclusionMode: ExclusionMode.Ignore
        visible: false
        implicitWidth: menuBackground.implicitWidth
        implicitHeight: menuBackground.implicitHeight

        color: "transparent"

        HyprlandFocusGrab {
            id: grab
            windows: [dropdown]
            onCleared: dropdown.visible = false
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
                    dropdown.visible = false;
                    grab.active = false;
                } else if ([Qt.Key_Right, Qt.Key_L].includes(event.key)) {
                    root.currentFocusIndex = Math.min(root.currentFocusIndex + 1, buttons.children.length - 1);
                } else if ([Qt.Key_Left, Qt.Key_H].includes(event.key)) {
                    root.currentFocusIndex = Math.max(root.currentFocusIndex - 1, 0);
                } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                    root.executeCurrentItem();
                }
            }

            RowLayout {
                id: buttons
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm
                PowerMenuButton {
                    text: "󰿅"
                    onClicked: root.menuAction("hyprctl dispatch exit")
                    index: 0
                }
                PowerMenuButton {
                    text: ""
                    onClicked: PatchBay.lockScreen()
                    index: 1
                }
                PowerMenuButton {
                    text: "󰤄"
                    onClicked: root.menuAction("hyprctl dispatch global quickshell:lockscreen && systemctl suspend")
                    index: 2
                }

                PowerMenuButton {
                    text: ""
                    onClicked: root.menuAction("reboot")
                    index: 3
                }

                PowerMenuButton {
                    text: ""
                    onClicked: root.menuAction("shutdown")
                    index: 4
                }
            }
        }
    }
}
