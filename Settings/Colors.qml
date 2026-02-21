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
        "Background": "#2D353B",
        "Background Lifted": "#343F44",
        "Background Highlighted": "#3D484D",
        "Background Success": "#425047",
        "Background Error": "#514045",
        "Background Warning": "#4D4C43",
        "Foreground": "#D3C6AA",
        "Success": "#A7C080",
        "Error": "#E67E80",
        "Warning": "#DBBC7F",
        "Orange": "#E69875",
        "Yellow": "#DBBC7F",
        "Green": "#A7C080",
    }

    property string background: userColors["Background"] ?? "#2D353B"
    property string backgroundLifted: userColors["Background Lifted"] ?? "#343F44"
    property string backgroundHighlighted: userColors["Background Highlighted"] ?? "#3D484D"
    property string backgroundSuccess: userColors["Background Success"] ?? "#425047"
    property string backgroundError: userColors["Background Error"] ?? "#514045"
    property string backgroundWarning: userColors["Background Warning"] ?? "#4D4C43"

    property string foreground: userColors["Foreground"] ?? "#D3C6AA"
    property string success: userColors["Success"] ?? "#A7C080"
    property string error: userColors["Error"] ?? "#E67E80"
    property string warning: userColors["Warning"] ?? "#DBBC7F"

    property string orange: userColors["Orange"] ?? "#E69875"
    property string yellow: userColors["Yellow"] ?? "#DBBC7F"
    property string green: userColors["Green"] ?? "#A7C080"

    function updateColors() {
        background = userColors["Background"] ?? "#2D353B";
        backgroundLifted = userColors["Background Lifted"] ?? "#343F44";
        backgroundHighlighted = userColors["Background Highlighted"] ?? "#3D484D";
        backgroundSuccess = userColors["Background Success"] ?? "#425047";
        backgroundError = userColors["Background Error"] ?? "#514045";
        backgroundWarning = userColors["Background Warning"] ?? "#4D4C43";
        foreground = userColors["Foreground"] ?? "#D3C6AA";
        success = userColors["Success"] ?? "#A7C080";
        error = userColors["Error"] ?? "#E67E80";
        warning = userColors["Warning"] ?? "#DBBC7F";
        orange = userColors["Orange"] ?? "#E69875";
        yellow = userColors["Yellow"] ?? "#DBBC7F";
        green = userColors["Green"] ?? "#A7C080";
    }

    function refreshThemes() {
        listFiles.running = true
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
        command: ['bash', '-c', `ls  $XDG_CONFIG_HOME/quickshell/Settings/${root.directory}`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.availableThemes = text.trim().split(/\s+/)
        }
    }
}
