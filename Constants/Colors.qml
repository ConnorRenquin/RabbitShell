pragma Singleton

import QtQuick

import qs.Services

QtObject {
    id: root

    property var currentTheme: ThemeManager.theme

    // Base colors
    readonly property string background: currentTheme.background
    readonly property string foreground: currentTheme.foreground

    // Background levels (for layering UI elements)
    readonly property string bg1: currentTheme.bg1
    readonly property string bg2: currentTheme.bg2

    // Primary accent colors
    readonly property string primary: currentTheme.primary
    readonly property string secondary: currentTheme.secondary
    readonly property string accent: currentTheme.accent

    // Semantic colors (use these for consistency)
    readonly property string success: currentTheme.success
    readonly property string backgroundSuccess: currentTheme.backgroundSuccess
    readonly property string error: currentTheme.error
    readonly property string backgroundError: currentTheme.backgroundError
    readonly property string warning: currentTheme.warning
    readonly property string backgroundWarning: currentTheme.backgroundWarning

    // Extended color palette
    readonly property string orange: currentTheme.orange
    readonly property string yellow: currentTheme.yellow
    readonly property string green: currentTheme.green
    readonly property string aqua: currentTheme.aqua
    readonly property string blue: currentTheme.blue
    readonly property string purple: currentTheme.purple
    readonly property string gray: currentTheme.gray
}
