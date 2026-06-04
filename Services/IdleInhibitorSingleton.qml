pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick

import qs.Settings

Singleton {
    id: root

    property var lockTimeout: Settings.get('lockTimeout')?.value ?? 60
    property var suspendTimeout: Settings.get('suspendTimeout')?.value ?? 120
    property bool inhibitIdle: Settings.get('inhibitIdle')?.value ?? false

    function init() {
        console.log('IdleInhibitorSingleton -----------------------------------------');
    }

    function enabled() {
        return inhibitor.enabled
    }

    function toggle() {
        var currentStatus = Settings.get('inhibitIdle').value;
        Settings.change({
            name: 'inhibitIdle',
            value: !currentStatus
        });
    }

    GlobalShortcut {
        name: "idle-toggle"
        onPressed: root.toggle()
    }

    IdleInhibitor {
        id: inhibitor
        enabled: root.inhibitIdle;
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            mask: Region {}
        }
    }

    IdleMonitor {
        respectInhibitors: true
        timeout: root.lockTimeout
        onIsIdleChanged: {
            if (isIdle && !root.inhibitIdle) {
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
        interval: root.suspendTimeout * 1000
        onTriggered: System.suspend()
    }
}
