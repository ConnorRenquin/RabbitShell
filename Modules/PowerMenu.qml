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

    Component.onCompleted: PatchBay.openPowerMenu.connect(toggle)

    GlobalShortcut {
        name: "powermenu"
        onPressed: loader.toggle()
    }

    sourceComponent: PanelWindow {
        id: root

        property bool topBar: Settings.get('barPosition').value
        anchors.top: true
        margins.top: topBar ? Styles.marginMd * 3 : Styles.marginSm
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: menuBackground.implicitWidth
        implicitHeight: menuBackground.implicitHeight
        color: "transparent"

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        Rectangle {
            id: menuBackground
            color: Colors.surface
            radius: Styles.marginSm
            implicitHeight: 70
            implicitWidth: buttons.implicitWidth + Styles.marginSm * 2
            focus: true

            Controls {
                id: controls
            }

            Keys.onPressed: event => {
                if (controls.quitPressed(event)) {
                    loader.active = false;
                } else if (controls.rightPressed(event)) {
                    loader.currentFocusIndex = Math.min(loader.currentFocusIndex + 1, buttons.children.length - 1);
                } else if (controls.leftPressed(event)) {
                    loader.currentFocusIndex = Math.max(loader.currentFocusIndex - 1, 0);
                } else if (controls.enterPressed(event)) {
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
                    text: Icons.logout
                    onClicked: System.logout()
                    index: 0
                }
                PowerMenuButton {
                    text: Icons.lock
                    onClicked: PatchBay.lockScreen()
                    index: 1
                }
                PowerMenuButton {
                    text: Icons.suspend
                    onClicked: System.suspend()
                    index: 2
                }

                PowerMenuButton {
                    text: Icons.reboot
                    onClicked: System.reboot()
                    index: 3
                }

                PowerMenuButton {
                    text: Icons.power
                    onClicked: System.shutdown()
                    index: 4
                }

                PowerMenuButton {
                    text: Icons.firmware
                    onClicked: System.firmware()
                    index: 5
                }
            }
        }
    }

    component PowerMenuButton: ButtonStyled {
        id: menuButton
        required property int index
        Layout.fillWidth: true
        isFocused: index === loader.currentFocusIndex
    }
}
