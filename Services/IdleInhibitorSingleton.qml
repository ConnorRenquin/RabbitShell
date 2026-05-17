pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick

Singleton {
    id: root

    function init() {
        console.log('IdleInhibitorSingleton -----------------------------------------');
    }

    function enabled() {
        return inhibitor.enabled
    }

    function toggle() {
        inhibitor.enabled = !inhibitor.enabled;
    }

    GlobalShortcut {
        name: "idleToggle"
        onPressed: root.toggle()
    }

    IdleInhibitor {
        id: inhibitor
        enabled: true
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            mask: Region {}
        }
    }

    IdleMonitor {
        respectInhibitors: true
        timeout: 600
        onIsIdleChanged: {
            if (isIdle) {
                Quickshell.execDetached(["sh", "-c", "hyprctl dispatch 'hl.dsp.global(\"quickshell:lockscreen\")' && systemctl suspend"])
            }
        }
    }
}
