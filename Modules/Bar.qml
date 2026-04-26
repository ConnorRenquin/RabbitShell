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

        screen: modelData
        implicitHeight: 48
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        property int margin: Styles.marginSm
        margins {
            top: margin
            bottom: 0 // Hyprland takes care of this margin, so you don't have to.
            left: margin
            right: margin
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

        Rectangle {
            anchors.fill: parent
            radius: Styles.radiusMd
            color: Colors.background
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

}
