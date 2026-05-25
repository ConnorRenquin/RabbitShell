import Quickshell

import QtQuick

import qs.Services
import qs.Settings

import qs.Modules
import qs.Modules.Clipboard
import qs.Modules.SettingsMenu
import qs.Modules.Bar

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
    TimeManager {}
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
