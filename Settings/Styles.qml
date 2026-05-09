pragma Singleton

import Quickshell

import QtQuick

Singleton {
    id: root

    property string defaultFontFamily: 'RobotoMono Nerd Font Propo'

    readonly property int barTextOffset: 2

    readonly property int marginXS: marginSm / 2
    property int marginSm: 10
    readonly property int marginMd: marginSm * 2
    readonly property int marginLg: marginSm * 3

    property int radiusSm: 5
    readonly property int radiusMd: radiusSm * 2
    readonly property int radiusLg: radiusSm * 3

    readonly property int textXS: textSm * 0.8
    property int textSm: 10
    readonly property int textMd: textSm * 1.2
    readonly property int textLg: textSm * 2.0

    Component.onCompleted: {
        defaultFontFamily = Settings.register({ name: 'fontFamily', value: 'RobotoMono Nerd Font Propo' }).value;
        marginSm = Settings.register({ name: 'margin', value: 10 }).value;
        radiusSm = Settings.register({ name: 'radius', value: 5 }).value;
        textSm = Settings.register({ name: 'textSize', value: 10 }).value;
    }

    Connections {
        target: Settings
        function onSettingsChanged() {
            const s = Settings.settings;
            const fontFamily = s.find(x => x.name === 'fontFamily');
            if (fontFamily) root.defaultFontFamily = fontFamily.value;
            const margin = s.find(x => x.name === 'margin');
            if (margin) root.marginSm = margin.value;
            const radius = s.find(x => x.name === 'radius');
            if (radius) root.radiusSm = radius.value;
            const textSize = s.find(x => x.name === 'textSize');
            if (textSize) root.textSm = textSize.value;
        }
    }
}
