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
        return persist.isEnabled;
    }

    function toggle() {
        persist.isEnabled = !persist.isEnabled;
    }

    PersistentProperties {
        id: persist
        reloadableId: "persistedStates"
        property bool isEnabled: false
    }

    GlobalShortcut {
        name: "idleToggle"
        onPressed: root.toggle()
    }

    IdleInhibitor {
        enabled: persist.isEnabled
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            mask: Region {}
        }
    }
}
