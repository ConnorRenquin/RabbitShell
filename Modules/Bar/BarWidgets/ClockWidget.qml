import QtQuick

import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services
import qs.Helpers

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
            Layout.preferredWidth: contentRow.aWidth / 3
            ButtonStyled {
                id: button
                anchors.fill: parent
                text: Icons.apps
                defaultColor: theme.background
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
