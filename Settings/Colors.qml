pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string currentTheme: GlobalSettings.currentTheme ?? "default.json"
    readonly property string directory: '.data/colors/'
    property string themePath: directory + currentTheme
    property list<string> availableThemes: []
    property bool isLoadingTheme: false

    property var userColors: {
        "surface": "#2D353B",
        "onSurface": "#D3C6AA",
        "primary": "#A7C080",
        "error": "#E67E80",
        "tertiary": "#DBBC7F",
    }

    property double lighter: 2.5
    property double darker: 1.5

    property string surface: userColors["surface"] ?? "#2D353B"
    property string surfaceContainer: Qt.lighter(Colors.surface, lighter) ?? "#343F44"
    property string surfaceContainerHigh: Qt.darker(Colors.surface, darker) ?? "#343F44"

    property string onSurface: userColors["onSurface"] ?? "#D3C6AA"

    property string primary: userColors["primary"] ?? "#A7C080"
    property string primaryDarker: Qt.darker(Colors.primary, darker) ?? "#425047"

    property string error: userColors["error"] ?? "#E67E80"
    property string errorDarker: Qt.darker(Colors.error, Colors.darker) ?? "#514045"

    property string tertiary: userColors["tertiary"] ?? "#DBBC7F"

    function updateColors() {
        surface = userColors["surface"] ?? "#2D353B";
        onSurface = userColors["onSurface"] ?? "#D3C6AA";
        primary = userColors["primary"] ?? "#A7C080";
        error = userColors["error"] ?? "#E67E80";
        tertiary = userColors["tertiary"] ?? "#DBBC7F";
    }

    function refreshThemes() {
        listFiles.running = true;
    }

    onUserColorsChanged: {
        root.updateColors();
        if (persistantData.loaded && !isLoadingTheme) {
            persistantData.setText(JSON.stringify(root.userColors));
        }
    }

    onCurrentThemeChanged: {
        GlobalSettings.currentTheme = currentTheme;
        persistantData.reload();
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl(root.themePath)
        blockLoading: false
        onLoaded: {
            root.isLoadingTheme = true;
            try {
                root.userColors = JSON.parse(text());
                root.updateColors();
            } catch (e) {
                console.log('Failed to parse userColors data:', e);
                root.userColors = root.userColors;
            }
            root.isLoadingTheme = false;
        }
        onLoadFailed: {
            console.log('Load failed, creating theme file:', root.themePath);
            Quickshell.execDetached(['touch', root.themePath]);
            persistantData.setText(JSON.stringify(root.userColors));
        }
        onSaveFailed: console.log('Failed to save userColors data')
    }

    Process {
        id: listFiles
        command: ['bash', '-c', `ls  $HOME/.config/quickshell/Settings/${root.directory}`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.availableThemes = text.trim().split(/\s+/)
        }
    }
}
