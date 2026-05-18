pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick

import qs.Services

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
        enabled: false
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            mask: Region {}
        }
    }

    IdleMonitor {
        respectInhibitors: true
        timeout: 60
        onIsIdleChanged: {
            if (isIdle) {
                PatchBay.lockScreen()
                suspendTimer.running = true;
                suspendTimer.restart()
            } else {
                suspendTimer.running = false;
            }
        }
    }
    Timer {
        id: suspendTimer
        running: false
        interval: 120 * 1000
        onTriggered: System.suspend()
    }
}
