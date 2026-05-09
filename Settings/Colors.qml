pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick


Singleton {
    id: root

    property string currentTheme: 'default.json'

    Component.onCompleted: {
        currentTheme = Settings.register({ name: 'currentTheme', value: 'default.json', category: 'appearance' }).value;
    }

    Connections {
        target: Settings
        function onSettingsChanged() {
            const live = Settings.settings.find(x => x.name === 'currentTheme');
            if (live && live.value !== root.currentTheme) {
                root.currentTheme = live.value;
            }
        }
    }
    readonly property string directory: '.data/colors/'
    readonly property string themePath: directory + currentTheme
    property list<string> availableThemes: []
    property bool isLoadingTheme: false

    property var userColors: {
        "primary": "#A7C080",
        "onPrimary": "#FFFFFF",
        "primaryContainer": "#D8F0BB",
        "onPrimaryContainer": "#1F3A0F",
        "inversePrimary": "#4A7C45",
        "secondary": "#8DA9A0",
        "onSecondary": "#FFFFFF",
        "secondaryContainer": "#C8E3D9",
        "onSecondaryContainer": "#0F2D27",
        "tertiary": "#DBBC7F",
        "onTertiary": "#FFFFFF",
        "tertiaryContainer": "#F5DFA8",
        "onTertiaryContainer": "#3A2D00",
        "error": "#E67E80",
        "onError": "#FFFFFF",
        "surface": "#2D353B",
        "onSurface": "#D3C6AA",
        "surfaceVariant": "#3D4A51",
        "onSurfaceVariant": "#A0B0B8",
        "outline": "#6A7F88",
        "outlineVariant": "#3D4A51",
        "background": "#232A2E",
        "onBackground": "#D3C6AA",
        "shadow": "#000000",
        "scrim": "#000000",
    }

    property double lighter: 2.5
    property double darker: 1.5

    // Primary
    property string primary: userColors["primary"] ?? "#A7C080"
    property string primaryLighter: Qt.lighter(root.primary, lighter)
    property string primaryDarker: Qt.darker(root.primary, darker)
    property string onPrimary: userColors["onPrimary"] ?? "#FFFFFF"
    property string primaryContainer: userColors["primaryContainer"] ?? "#D8F0BB"
    property string primaryContainerLighter: Qt.lighter(root.primaryContainer, lighter)
    property string primaryContainerDarker: Qt.darker(root.primaryContainer, darker)
    property string onPrimaryContainer: userColors["onPrimaryContainer"] ?? "#1F3A0F"
    property string inversePrimary: userColors["inversePrimary"] ?? "#4A7C45"

    // Secondary
    property string secondary: userColors["secondary"] ?? "#8DA9A0"
    property string secondaryLighter: Qt.lighter(root.secondary, lighter)
    property string secondaryDarker: Qt.darker(root.secondary, darker)
    property string onSecondary: userColors["onSecondary"] ?? "#FFFFFF"
    property string secondaryContainer: userColors["secondaryContainer"] ?? "#C8E3D9"
    property string secondaryContainerLighter: Qt.lighter(root.secondaryContainer, lighter)
    property string secondaryContainerDarker: Qt.darker(root.secondaryContainer, darker)
    property string onSecondaryContainer: userColors["onSecondaryContainer"] ?? "#0F2D27"

    // Tertiary
    property string tertiary: userColors["tertiary"] ?? "#DBBC7F"
    property string tertiaryLighter: Qt.lighter(root.tertiary, lighter)
    property string tertiaryDarker: Qt.darker(root.tertiary, darker)
    property string onTertiary: userColors["onTertiary"] ?? "#FFFFFF"
    property string tertiaryContainer: userColors["tertiaryContainer"] ?? "#F5DFA8"
    property string tertiaryContainerLighter: Qt.lighter(root.tertiaryContainer, lighter)
    property string tertiaryContainerDarker: Qt.darker(root.tertiaryContainer, darker)
    property string onTertiaryContainer: userColors["onTertiaryContainer"] ?? "#3A2D00"

    // Error
    property string error: userColors["error"] ?? "#E67E80"
    property string errorLighter: Qt.lighter(root.error, lighter)
    property string errorDarker: Qt.darker(root.error, darker)
    property string onError: userColors["onError"] ?? "#FFFFFF"

    // Surface
    property string surface: userColors["surface"] ?? "#2D353B"
    property string surfaceLighter: Qt.lighter(root.surface, lighter)
    property string surfaceDarker: Qt.darker(root.surface, darker)
    property string onSurface: userColors["onSurface"] ?? "#D3C6AA"
    property string surfaceVariant: userColors["surfaceVariant"] ?? "#3D4A51"
    property string surfaceVariantLighter: Qt.lighter(root.surfaceVariant, lighter)
    property string surfaceVariantDarker: Qt.darker(root.surfaceVariant, darker)
    property string onSurfaceVariant: userColors["onSurfaceVariant"] ?? "#A0B0B8"

    // Outline
    property string outline: userColors["outline"] ?? "#6A7F88"
    property string outlineVariant: userColors["outlineVariant"] ?? "#3D4A51"

    // Background
    property string background: userColors["background"] ?? "#232A2E"
    property string backgroundLighter: Qt.lighter(root.background, lighter)
    property string backgroundDarker: Qt.darker(root.background, darker)
    property string onBackground: userColors["onBackground"] ?? "#D3C6AA"

    // Misc
    property string shadow: userColors["shadow"] ?? "#000000"
    property string scrim: userColors["scrim"] ?? "#000000"

    function updateColors() {
        primary = userColors["primary"] ?? "#A7C080";
        onPrimary = userColors["onPrimary"] ?? "#FFFFFF";
        primaryContainer = userColors["primaryContainer"] ?? "#D8F0BB";
        onPrimaryContainer = userColors["onPrimaryContainer"] ?? "#1F3A0F";
        inversePrimary = userColors["inversePrimary"] ?? "#4A7C45";

        secondary = userColors["secondary"] ?? "#8DA9A0";
        onSecondary = userColors["onSecondary"] ?? "#FFFFFF";
        secondaryContainer = userColors["secondaryContainer"] ?? "#C8E3D9";
        onSecondaryContainer = userColors["onSecondaryContainer"] ?? "#0F2D27";

        tertiary = userColors["tertiary"] ?? "#DBBC7F";
        onTertiary = userColors["onTertiary"] ?? "#FFFFFF";
        tertiaryContainer = userColors["tertiaryContainer"] ?? "#F5DFA8";
        onTertiaryContainer = userColors["onTertiaryContainer"] ?? "#3A2D00";

        error = userColors["error"] ?? "#E67E80";
        onError = userColors["onError"] ?? "#FFFFFF";

        surface = userColors["surface"] ?? "#2D353B";
        onSurface = userColors["onSurface"] ?? "#D3C6AA";
        surfaceVariant = userColors["surfaceVariant"] ?? "#3D4A51";
        onSurfaceVariant = userColors["onSurfaceVariant"] ?? "#A0B0B8";

        outline = userColors["outline"] ?? "#6A7F88";
        outlineVariant = userColors["outlineVariant"] ?? "#3D4A51";

        background = userColors["background"] ?? "#232A2E";
        onBackground = userColors["onBackground"] ?? "#D3C6AA";

        shadow = userColors["shadow"] ?? "#000000";
        scrim = userColors["scrim"] ?? "#000000";
    }

    function refreshThemes() {
        listFiles.running = true;
    }

    function reloadTheme() {
        persistantData.reload();
    }

    onUserColorsChanged: {
        root.updateColors();
        if (persistantData.loaded && !isLoadingTheme) {
            persistantData.setText(JSON.stringify(root.userColors));
        }
    }

    onCurrentThemeChanged: {
        persistantData.reload();
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl(root.themePath)
        blockLoading: false
        onLoaded: {
            const raw = text();
            root.isLoadingTheme = true;
            try {
                root.userColors = JSON.parse(raw);
                root.updateColors();
            } catch (e) {
                root.userColors = root.userColors;
            }
            root.isLoadingTheme = false;
        }
        onLoadFailed: {
            Quickshell.execDetached(['touch', root.themePath]);
            persistantData.setText(JSON.stringify(root.userColors));
        }
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
