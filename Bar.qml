import Quickshell
import Quickshell.Hyprland

import QtQuick

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
        implicitHeight: 45
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

        // Left
        BarRow {
            anchors.left: parent.left
            ButtonStyled {
                id: appsButton
                implicitHeight: parent.height
                text: "󰘳"
                onClicked: Hyprland.dispatch("togglespecialworkspace")
            }
            WorkspacesWidget {
                monitorName: root.modelData.name
            }
            WindowTitleWidget {}
        }

        // Center
        BarRow {
            anchors.centerIn: parent
            ButtonStyled {
                id: notificationsButton
                visible: Notifications.notifications.values.length > 0
                text: " " + Notifications.notifications.values.length
                onClicked: PatchBay.openNotificationsManager()
            }
            ClockWidget {}
            BatteryWidget {}
        }

        // Right
        BarRow {
            anchors.right: parent.right
            MediaWidget {}
            SystemTrayWidget {}
            IdleInhibitorWidget {}
            ButtonStyled {
                id: settingsButton
                height: parent.height
                text: ""
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        WallpaperSettings.setRandomWallpaper();
                    } else if (mouse.button === Qt.LeftButton) {
                        PatchBay.openThemeSelector();
                    }
                }
            }
        }
    }

    component BarRow: Row {
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        spacing: 8
    }
}
