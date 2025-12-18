import Quickshell
import QtQuick

import qs.BarWidgets

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

        property int margin: 8
        margins {
            top: margin
            bottom: 0 // Hyprland takes care of this margin, so you don't have to.
            left: margin
            right: margin
        }

        // Left
        BarRow {
            anchors.left: parent.left
            WorkspacesWidget {
                monitorName: root.modelData.name
            }
            WindowTitleWidget {}
        }

        // Center
        BarRow {
            anchors.centerIn: parent
            ClockWidget {}
            BatteryWidget {}
        }

        // Right
        BarRow {
            anchors.right: parent.right
            MediaWidget {}
            SystemTray {}
            IdleInhibitorWidget {}
            ButtonWidget {
                icon: "󱪵"
                command: "waypaper --random"
            }
            PowerButton {}
        }
    }

    component BarRow: Row {
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        spacing: 8
    }
}
