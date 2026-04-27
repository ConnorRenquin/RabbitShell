import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.BarWidgets
import qs.Services
import qs.Components
import qs.Settings

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root

        required property var modelData

        property bool top: Settings.register({
            name: 'Bar Position',
            value: true
        }).value

        screen: modelData
        implicitHeight: 48
        color: "transparent"

        anchors {
            top: top
            left: true
            right: true
            bottom: !top
        }

        property int margin: Styles.marginSm
        margins {
            top: margin
            // Hyprland takes care of this margin, so you don't have to.
            bottom: top ? 0 : margin
            left: !top ? margin : 0
            right: margin
        }

        Rectangle {
            anchors.fill: parent
            radius: Styles.radiusMd

            property bool barBackground: Settings.register({
                name: 'Bar Background',
                value: true
            }).value
            color: barBackground ? Colors.background : 'transparent'
            BarRow {
                id: leftGroup
                anchors.left: parent.left
                BarButton {
                    id: appsButton
                    text: "󰘳"
                    onClicked: Hyprland.dispatch("togglespecialworkspace")
                }
                WorkspacesWidget {
                    monitorName: root.modelData.name
                }
                WindowTitleWidget {}
            }
            BarRow {
                id: centerGroup
                anchors.centerIn: parent
                BarButton {
                    id: notificationsButton
                    visible: Notifications.notifications.values.length > 0
                    text: " " + Notifications.notifications.values.length
                    onClicked: PatchBay.openNotificationsManager()
                }
                ClockWidget {}
                BatteryWidget {}
            }
            BarRow {
                id: rightGroup
                anchors.right: parent.right
                MediaWidget {}
                SystemTrayWidget {}
                IdleInhibitorWidget {}
                BarButton {
                    id: settingsButton
                    text: ""
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            WallpaperSettings.setRandomWallpaper();
                        } else if (mouse.button === Qt.LeftButton) {
                            PatchBay.openSettings();
                        }
                    }
                }
            }
        }
    }

    component BarRow: RowLayout {
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        spacing: Styles.marginXS
    }

    component BarButton: ButtonStyled {
        Layout.fillHeight: true
    }
}
