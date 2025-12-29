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
    readonly property string bg0: currentTheme.bg0
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

    function withOpacity(color, opacity) {
        return Qt.rgba(Qt.colorFromString(color).r, Qt.colorFromString(color).g, Qt.colorFromString(color).b, opacity);
    }

    function lighten(color, amount) {
        var c = Qt.colorFromString(color);
        return Qt.rgba(Math.min(1, c.r + amount), Math.min(1, c.g + amount), Math.min(1, c.b + amount), c.a);
    }

    function darken(color, amount) {
        var c = Qt.colorFromString(color);
        return Qt.rgba(Math.max(0, c.r - amount), Math.max(0, c.g - amount), Math.max(0, c.b - amount), c.a);
    }

    function mix(color1, color2, ratio) {
        var c1 = Qt.colorFromString(color1);
        var c2 = Qt.colorFromString(color2);
        return Qt.rgba(c1.r * ratio + c2.r * (1 - ratio), c1.g * ratio + c2.g * (1 - ratio), c1.b * ratio + c2.b * (1 - ratio), c1.a * ratio + c2.a * (1 - ratio));
    }
}
