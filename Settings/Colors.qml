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
        "Foreground": "#D3C6AA",
        "Primary": "#A7C080",
        "Secondary": "#7FBBB3",
        "Accent": "#E69875",
        "Success": "#A7C080",
        "Background Success": "#425047",
        "Error": "#E67E80",
        "Background Error": "#514045",
        "Warning": "#DBBC7F",
        "Background Warning": "#4D4C43",
        "Orange": "#E69875",
        "Yellow": "#DBBC7F",
        "Green": "#A7C080",
        "Aqua": "#83C092",
        "Blue": "#7FBBB3",
        "Purple": "#D699B6",
        "Gray": "#7A8478"
    }

    // Base colors
    property string background: userColors["Background"] ?? "#2D353B"
    property string backgroundLifted: userColors["Background Lifted"] ?? "#343F44"
    property string backgroundHighlighted: userColors["Background Highlighted"] ?? "#3D484D"
    property string foreground: userColors["Foreground"] ?? "#D3C6AA"

    // Primary accent colors
    property string primary: userColors["Primary"] ?? "#A7C080"
    property string secondary: userColors["Secondary"] ?? "#7FBBB3"
    property string accent: userColors["Accent"] ?? "#E69875"

    // Semantic colors (use these for consistency)
    property string success: userColors["Success"] ?? "#A7C080"
    property string backgroundSuccess: userColors["Background Success"] ?? "#425047"
    property string error: userColors["Error"] ?? "#E67E80"
    property string backgroundError: userColors["Background Error"] ?? "#514045"
    property string warning: userColors["Warning"] ?? "#DBBC7F"
    property string backgroundWarning: userColors["Background Warning"] ?? "#4D4C43"

    // Extended color palette
    property string orange: userColors["Orange"] ?? "#E69875"
    property string yellow: userColors["Yellow"] ?? "#DBBC7F"
    property string green: userColors["Green"] ?? "#A7C080"
    property string aqua: userColors["Aqua"] ?? "#83C092"
    property string blue: userColors["Blue"] ?? "#7FBBB3"
    property string purple: userColors["Purple"] ?? "#D699B6"
    property string gray: userColors["Gray"] ?? "#7A8478"

    function updateColors() {
        background = userColors["Background"] ?? "#2D353B";
        backgroundLifted = userColors["Background Lifted"] ?? "#343F44";
        backgroundHighlighted = userColors["Background Highlighted"] ?? "#3D484D";
        foreground = userColors["Foreground"] ?? "#D3C6AA";
        primary = userColors["Primary"] ?? "#A7C080";
        secondary = userColors["Secondary"] ?? "#7FBBB3";
        accent = userColors["Accent"] ?? "#E69875";
        success = userColors["Success"] ?? "#A7C080";
        backgroundSuccess = userColors["Background Success"] ?? "#425047";
        error = userColors["Error"] ?? "#E67E80";
        backgroundError = userColors["Background Error"] ?? "#514045";
        warning = userColors["Warning"] ?? "#DBBC7F";
        backgroundWarning = userColors["Background Warning"] ?? "#4D4C43";
        orange = userColors["Orange"] ?? "#E69875";
        yellow = userColors["Yellow"] ?? "#DBBC7F";
        green = userColors["Green"] ?? "#A7C080";
        aqua = userColors["Aqua"] ?? "#83C092";
        blue = userColors["Blue"] ?? "#7FBBB3";
        purple = userColors["Purple"] ?? "#D699B6";
        gray = userColors["Gray"] ?? "#7A8478";
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
