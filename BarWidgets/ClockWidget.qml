import QtQuick

import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root
    radius: Styles.radiusSm
    color: theme.background

    Themer {
        id: theme
        settingName: 'clockColor'
    }

    implicitWidth: contentRow.implicitWidth + Styles.marginSm * 3

    RowLayout {
        id: contentRow
        spacing: Styles.marginSm
        anchors.centerIn: parent

        property int aWidth: 150

        TextStyled {
            id: clock
            text: Time.getSymbol() + " " + Time.getTime()
            Layout.preferredWidth: contentRow.aWidth
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 40
            ButtonStyled {
                id: button
                text: Icons.os
                anchors.fill: parent
                defaultColor: theme.foreground
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
        }

        TextStyled {
            id: date
            text: Time.date + " 󰃭"
            Layout.preferredWidth: contentRow.aWidth
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
