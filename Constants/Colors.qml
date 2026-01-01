pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import qs.Services

Singleton {
    id: root

    property var currentTheme: ThemeManager.theme

    property var userColors: {
        "Background": currentTheme.background,
        "Background Lifted": currentTheme.backgroundLifted,
        "Background Highlighted": currentTheme.backgroundHighlighted,
        "Foreground": currentTheme.foreground,
        "Primary": currentTheme.primary,
        "Secondary": currentTheme.secondary,
        "Accent": currentTheme.accent,
        "Success": currentTheme.success,
        "Background Success": currentTheme.backgroundSuccess,
        "Error": currentTheme.error,
        "Background Error": currentTheme.backgroundError,
        "Warning": currentTheme.warning,
        "Background Warning": currentTheme.backgroundWarning,
        "Orange": currentTheme.orange,
        "Yellow": currentTheme.yellow,
        "Green": currentTheme.green,
        "Aqua": currentTheme.aqua,
        "Blue": currentTheme.blue,
        "Purple": currentTheme.purple,
        "Gray": currentTheme.gray
    }

    // Base colors
    readonly property string background: userColors["Background"] ?? currentTheme.background
    readonly property string backgroundLifted: userColors["Background Lifted"] ?? currentTheme.backgroundLifted
    readonly property string backgroundHighlighted: userColors["Background Highlighted"] ?? currentTheme.backgroundHighlighted
    readonly property string foreground: userColors["Foreground"] ?? currentTheme.foreground

    // Primary accent colors
    readonly property string primary: userColors["Primary"] ?? currentTheme.primary
    readonly property string secondary: userColors["Secondary"] ?? currentTheme.secondary
    readonly property string accent: userColors["Accent"] ?? currentTheme.accent

    // Semantic colors (use these for consistency)
    readonly property string success: userColors["Success"] ?? currentTheme.success
    readonly property string backgroundSuccess: userColors["Background Success"] ?? currentTheme.backgroundSuccess
    readonly property string error: userColors["Error"] ?? currentTheme.error
    readonly property string backgroundError: userColors["Background Error"] ?? currentTheme.backgroundError
    readonly property string warning: userColors["Warning"] ?? currentTheme.warning
    readonly property string backgroundWarning: userColors["Background Warning"] ?? currentTheme.backgroundWarning

    // Extended color palette
    readonly property string orange: userColors["Orange"] ?? currentTheme.orange
    readonly property string yellow: userColors["Yellow"] ?? currentTheme.yellow
    readonly property string green: userColors["Green"] ?? currentTheme.green
    readonly property string aqua: userColors["Aqua"] ?? currentTheme.aqua
    readonly property string blue: userColors["Blue"] ?? currentTheme.blue
    readonly property string purple: userColors["Purple"] ?? currentTheme.purple
    readonly property string gray: userColors["Gray"] ?? currentTheme.gray

    onUserColorsChanged: {
        if (persistantData.loaded) {
            console.log('colors changed');
            persistantData.setText(JSON.stringify(root.userColors));
        }
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/user-colors.json')
        blockLoading: false
        onLoaded: {
            try {
                root.userColors = JSON.parse(persistantData.text());
            } catch (e) {
                console.log('Failed to parse userColors data:', e);
                root.userColors = root.userColors;
            }
        }
        onLoadFailed: {
            Quickshell.execDetached(['touch', '.data/user-colors.json']);
            persistantData.setText(JSON.stringify(root.userColors));
        }
        onSaveFailed: console.log('Failed to save userColors data')
    }
}
