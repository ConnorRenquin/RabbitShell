import Quickshell
import Quickshell.Hyprland

import QtQuick

import qs.Services
import qs.Components

PanelWindow {
    color: "transparent"
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    visible: true
    exclusionMode: ExclusionMode.Ignore

    onVisibleChanged: {
        HyprctlClients.watch = visible;
    }

    Repeater {
        model: HyprctlClients.clients.filter((client) => Hyprland.focusedWorkspace.id === client.workspaceId)
        delegate: Rectangle {
            required property ClientInfo modelData

            property var clientMonitor: Hyprland.monitors.values.find(m => m.id === modelData.monitor)

            width: 40
            height: 30
            // Subtract monitor offset from absolute coordinates, then center in window
            x: modelData.at[0] - (clientMonitor?.x ?? 0) + modelData.size[0] / 2 - width / 2
            y: modelData.at[1] - (clientMonitor?.y ?? 0) + modelData.size[1] / 2 - height / 2

            color: "red"
            border.color: "white"
            border.width: 2

            TextStyled {
                anchors.centerIn: parent
                text: "eyy"
            }
        }
    }
}
