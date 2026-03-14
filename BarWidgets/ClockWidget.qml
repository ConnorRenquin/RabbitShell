import QtQuick

import Quickshell
import Quickshell.Hyprland

import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root

    property int currentFocusIndex: 0

    implicitWidth: contentRow.implicitWidth + Styles.marginSm * 2
    radius: Styles.radiusSm
    color: Colors.background
    implicitHeight: parent.height
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Styles.marginSm
        TextStyled {
            text: Time.time
        }
        ButtonStyled {
            text: "󱄅"
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    dropdown.visible = !dropdown.visible;
                } else if (mouse.button === Qt.MiddleButton) {
                    Hyprland.dispatch("togglespecialworkspace");
                } else if (mouse.button === Qt.RightButton) {
                    PatchBay.openMixer();
                }
            }
        }

        TextStyled {
            text: Time.date
        }
    }

    function executeCurrentItem() {
        if (currentFocusIndex >= 0 && currentFocusIndex < buttons.children.length) {
            buttons.children[currentFocusIndex].clicked(null);
        }
    }

    GlobalShortcut {
        name: "powermenu"
        onPressed: dropdown.visible = !dropdown.visible;
    }

    function menuAction(command) {
        dropdown.visible = false;
        Quickshell.execDetached(["bash", "-c", command]);
    }

    HyprlandFocusGrab {
        active: dropdown.visible
        windows: [dropdown]
        onCleared: dropdown.visible = false
    }

    PanelWindow {
        id: dropdown

        visible: false

        anchors.top: true
        margins.top: Styles.marginMd * 3
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: menuBackground.implicitWidth
        implicitHeight: menuBackground.implicitHeight

        color: "transparent"

        component PowerMenuButton: ButtonStyled {
            id: menuButton
            required property int index
            Layout.fillWidth: true
            isFocused: index === root.currentFocusIndex
        }

        Rectangle {
            id: menuBackground
            color: Colors.background
            radius: Styles.marginSm
            implicitHeight: 70
            implicitWidth: buttons.implicitWidth + Styles.marginSm * 2
            focus: dropdown.visible

            Keys.onPressed: event => {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    dropdown.visible = false;
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
                    onClicked: root.menuAction("reboot now")
                    index: 3
                }

                PowerMenuButton {
                    text: ""
                    onClicked: root.menuAction("shutdown now")
                    index: 4
                }
            }
        }
    }
}
