pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Wayland

Singleton {
    id: root

    PersistentProperties {
        id: persist
        reloadableId: "persistedStates"
        property bool isEnabled: false
    }

    function enabled() {
        return persist.isEnabled;
    }

    function toggle() {
        persist.isEnabled = !persist.isEnabled;
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
