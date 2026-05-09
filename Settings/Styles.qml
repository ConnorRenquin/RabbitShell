pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    property string defaultFontFamily: 'RobotoMono Nerd Font Propo'
    property list<string> availableFonts: []

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

    // Fetch all system fonts via fc-list then register the setting once the list is ready.
    Process {
        id: fontListProcess
        command: ['bash', '-c', "fc-list : family | sed 's/,.*$//' | sort -u"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.availableFonts = text.trim().split('\n').filter(f => f.length > 0);
                // Register with options (no-op if already registered from saved settings).
                // Then always patch options in via change() so the dropdown is populated
                // regardless of whether the setting was registered before or after font list loaded.
                root.defaultFontFamily = Settings.register({
                    name: 'fontFamily',
                    value: 'RobotoMono Nerd Font Propo',
                    options: root.availableFonts,
                    category: 'misc'
                }).value;
                Settings.change({ name: 'fontFamily', options: root.availableFonts });
                root.marginSm = Settings.register({ name: 'margin', value: 10 }).value;
                root.radiusSm = Settings.register({ name: 'radius', value: 5 }).value;
                root.textSm = Settings.register({ name: 'textSize', value: 10 }).value;
            }
        }
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
