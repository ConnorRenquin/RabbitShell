pragma Singleton

import Quickshell

import QtQuick

Singleton {
    id: root

    readonly property string defaultFontFamily: Settings.register({
        name: 'Font Family',
        value: 'RobotoMono Nerd Font Propo'
    }).value

    readonly property int barTextOffset: 2

    readonly property int marginXS: marginSm / 2 ?? 10
    readonly property int marginSm: Settings.register({
        name: 'Margin',
        value: 10
    }).value
    readonly property int marginMd: marginSm * 2 ?? 20
    readonly property int marginLg: marginSm * 3 ?? 30

    readonly property int radiusSm: Settings.register({
        name: 'Radius',
        value: 5
    }).value
    readonly property int radiusMd: radiusSm * 2 ?? 10
    readonly property int radiusLg: radiusSm * 3 ?? 15

    readonly property int textXS: textSm * 0.8 ?? 12
    readonly property int textSm: Settings.register({
        name: 'Text',
        value: 10
    }).value
    readonly property int textMd: textSm * 1.2 ?? 20
    readonly property int textLg: textSm * 2.0 ?? 26
}
