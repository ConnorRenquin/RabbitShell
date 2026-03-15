import Quickshell
import Quickshell.Io

import QtQuick

import qs.Services

ShellRoot {
    Bar {}
    NotificationPopup {}
    Background {}
    AppLauncher {}
    Workspaces {}
    Mixer {}
    PowerMenu {}
    ToplevelView {}
    Clipboard {}
    // ImageClipboard {}
    NotificationManager {}
    LockScreen {}
    Polkit {}
    SettingsMenu {}
    AsciiEmojis {}
    // Test {}
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
