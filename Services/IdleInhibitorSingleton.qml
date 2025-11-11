pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Wayland

IdleInhibitor {
    enabled: false
    window: PanelWindow {
        implicitWidth: 0
        implicitHeight: 0
        color: "transparent"
        mask: Region {}
    }
}
