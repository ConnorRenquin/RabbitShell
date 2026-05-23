pragma Singleton

import Quickshell

import QtQuick

Singleton {
    id: root

    property string defaultFontFamily

    readonly property int barTextOffset: 2

    readonly property int marginXS: marginSm / 2
    property int marginSm
    readonly property int marginMd: marginSm * 2
    readonly property int marginLg: marginSm * 3

    property int radiusSm
    readonly property int radiusMd: radiusSm * 2
    readonly property int radiusLg: radiusSm * 3

    readonly property int textXS: textSm * 0.8
    property int textSm
    readonly property int textMd: textSm * 1.2
    readonly property int textLg: textSm * 2.0

    Component.onCompleted: {
        root.defaultFontFamily = Settings.register({
            name: 'fontFamily',
            value: 'JetBrainsMono Nerd Font Mono Propo',
            options: ['RobotoMono Nerd Font Propo', 'Agave Nerd Font Propo', 'JetBrainsMono Nerd Font Mono', 'SpaceMono Nerd Font Propo', 'Terminuss Nerd Font Mono'],
            category: 'appearance'
        }).value;
        root.marginSm = Settings.register({
            name: 'margin',
            value: 10,
            category: 'appearance'
        }).value;
        root.radiusSm = Settings.register({
            name: 'radius',
            value: 5,
            category: 'appearance'
        }).value;
        root.textSm = Settings.register({
            name: 'textSize',
            value: 10,
            category: 'appearance'
        }).value;
    }

    Connections {
        target: Settings
        function onSettingsChanged() {
            const fontFamily = Settings.get('fontFamily');
            if (fontFamily)
                root.defaultFontFamily = fontFamily.value;
            const margin = Settings.get('margin');
            if (margin)
                root.marginSm = margin.value;
            const radius = Settings.get('radius');
            if (radius)
                root.radiusSm = radius.value;
            const textSize = Settings.get('textSize');
            if (textSize)
                root.textSm = textSize.value;
        }
    }
}
