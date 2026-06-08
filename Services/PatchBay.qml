pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    signal openNotificationsManager
    signal lockScreen
    signal openSettings
    signal openAppLauncher
    signal openAsciiEmojis
    signal openNerdFonts
    signal openImageClipboard
    signal openMixer
    signal openPowerMenu

    IpcHandler {
        target: "patch"
        function settings() {
            root.openSettings()
        }
    }
}
