pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string currentTheme: "default.json"

    onCurrentThemeChanged: {
        if (persistantData.loaded) {
            var settings = {
                "Current Theme": currentTheme
            };
            persistantData.setText(JSON.stringify(settings, null, 2));
        }
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/global-settings.json')
        blockLoading: true
        onLoaded: {
            try {
                var loadedSettings = JSON.parse(persistantData.text());
                root.currentTheme = loadedSettings["Current Theme"] ?? "default.json";
                console.log('Global settings loaded. Current theme:', root.currentTheme);
            } catch (e) {
                console.error('Failed to parse global settings data:', e);
            }
        }
        onLoadFailed: {
            console.log('Global settings file not found, creating with defaults');
            Quickshell.execDetached(['touch', '.data/global-settings.json']);
            var defaultSettings = {
                "Current Theme": root.currentTheme
            };
            persistantData.setText(JSON.stringify(defaultSettings, null, 2));
        }
        onSaveFailed: console.error('Failed to save global settings data')
    }
}
