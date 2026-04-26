import QtQuick

import Quickshell
import Quickshell.Hyprland

import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root

    readonly property var clockSymbols: [
        "󱐿", "󱑀", "󱑁", "󱑂", "󱑃", "󱑄",
        "󱑅", "󱑆", "󱑇", "󱑈", "󱑉", "󱑊"
    ]

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
            text: root.clockSymbols[Time.hour % 12 - 1] + " |- " + Time.time
            Layout.preferredWidth: root.matchedWidth
            horizontalAlignment: Text.AlignRight
        }

        ButtonStyled {
            text: "󱄅"
            pointSize: Styles.textLg
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    PatchBay.openAppLauncher()
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
