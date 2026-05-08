import Quickshell

import QtQuick

import qs.Services
import qs.Modules

ShellRoot {
    Bar {}
    NotificationPopup {}
    Background {}
    AppLauncher {}
    Mixer {}
    PowerMenu {}
    ToplevelView {}
    Clipboard {}
    NotificationManager {}
    LockScreen {}
    Polkit {}
    SettingsMenu {}
    Component.onCompleted: {
        Qt.callLater(function () {
            Audio.init();
            Notifications.init();
            IdleInhibitorSingleton.init();
            ClipboardService.init();
            HyprctlClients.init();
            HyprctlMonitors.init();
        });
    }
}
