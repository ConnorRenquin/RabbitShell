import Quickshell

import QtQuick

import qs.Services
import qs.Settings
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
    TextEditor {}
    ScreenDraw {}
    Component.onCompleted: {
        Qt.callLater(function () {
            Settings.init();
            Audio.init();
            Notifications.init();
            IdleInhibitorSingleton.init();
            ClipboardService.init();
            HyprctlClients.init();
            HyprctlMonitors.init();
            SoundEffects.init();
        });
    }
}
