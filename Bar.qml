import Quickshell
import QtQuick

import qs.BarWidgets
import qs.Global
import qs.Constants

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {

        required property var modelData
        screen: modelData

        implicitHeight: 45
        color: Colors.transparent

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

        BarRow {
            anchors.left: parent.left

            WorkspacesWidget {
                monitorName: modelData.name
            }
        }

        BarRow {
            anchors.centerIn: parent

            ClockWidget {}
        }

        BarRow {
            anchors.right: parent.right

            SystemTray {}
            IdleInhibitorWidget {}
            PowerButton {}
        }
    }

    component BarRow: Row {
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
    }
}
