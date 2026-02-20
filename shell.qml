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
    ToplevelView {}
    Clipboard {}
    // ImageClipboard {}
    NotificationManager {}
    LockScreen {}
    Polkit {}
    SettingsMenu {}
    Cheatsheet {}
    // Test {}
    Component.onCompleted: {
        Qt.callLater(function () {
            HyprctlClients.init();
        });
    }
}
