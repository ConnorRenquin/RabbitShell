import QtQuick

import Quickshell
import Quickshell.Hyprland

import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root

    property real matchedWidth: Math.max(clock.implicitWidth, date.implicitWidth)

    implicitWidth: contentRow.implicitWidth + Styles.marginSm * 2
    radius: Styles.radiusSm
    color: Colors.surface

    Layout.fillHeight: true

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Styles.marginSm

        TextStyled {
            id: clock
            text: Time.getSymbol() + " |- " + Time.getTime()
            Layout.preferredWidth: root.matchedWidth
            horizontalAlignment: Text.AlignRight
        }

        ButtonStyled {
            text: "󱄅"
            pointSize: Styles.textLg
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    PatchBay.openAppLauncher();
                } else if (mouse.button === Qt.MiddleButton) {
                    PatchBay.openPowerMenu();
                } else if (mouse.button === Qt.RightButton) {
                    PatchBay.openMixer();
                }
            }
        }

        TextStyled {
            id: date
            text: Time.date + "  󰃭 "
            horizontalAlignment: Text.AlignLeft
            Layout.preferredWidth: root.matchedWidth
        }
    }
}
