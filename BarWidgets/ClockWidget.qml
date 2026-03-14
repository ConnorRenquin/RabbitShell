import QtQuick

import Quickshell
import Quickshell.Hyprland

import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root

    implicitWidth: contentRow.implicitWidth + Styles.marginSm * 2
    radius: Styles.radiusSm
    color: Colors.background
    implicitHeight: parent.height

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Styles.marginSm

        TextStyled {
            id: clock
            text: Time.time
        }

        ButtonStyled {
            text: "󱄅"
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    PatchBay.openPowerMenu();
                } else if (mouse.button === Qt.MiddleButton) {
                    Hyprland.dispatch("togglespecialworkspace");
                } else if (mouse.button === Qt.RightButton) {
                    PatchBay.openMixer();
                }
            }
        }

        TextStyled {
            text: Time.date
            Layout.preferredWidth: clock.width
        }
    }
}
