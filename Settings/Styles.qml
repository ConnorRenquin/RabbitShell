pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    property var userStyles: {
        "fontFamily": "RobotoMono Nerd Font Propo",
        "margin": 10,
        "radius": 5,
        "text": 12,
    }

    readonly property string defaultFontFamily: userStyles["Font Family"] ?? "RobotoMono Nerd Font Propo"
    readonly property int barTextOffset: 2
    readonly property int marginXS: marginSm / 2 ?? 10
    readonly property int marginSm: userStyles["margin"] ?? 10
    readonly property int marginMd: marginSm * 2 ?? 20
    readonly property int marginLg: marginSm * 3 ?? 30
    readonly property int radiusSm: userStyles["radius"] ?? 5
    readonly property int radiusMd: radiusSm * 2 ?? 10
    readonly property int radiusLg: radiusSm * 3 ?? 15
    readonly property int textXS: textSm * 0.8 ?? 12
    readonly property int textSm: userStyles["text"] ?? 18
    readonly property int textMd: textSm * 1.5 ?? 20
    readonly property int textLg: textSm * 2.5 ?? 26

    onUserStylesChanged: {
        if (persistantData.loaded) {
            persistantData.setText(JSON.stringify(root.userStyles));
        }
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/user-styles.json')
        blockLoading: false
        onLoaded: {
            try {
                root.userStyles = JSON.parse(persistantData.text());
            } catch (e) {
                console.error('Failed to parse userStyles data:', e);
                root.userStyles = root.userStyles;
            }
        }
        onLoadFailed: {
            Quickshell.execDetached(['touch', '.data/userStyles.json']);
            persistantData.setText(JSON.stringify(root.userStyles));
        }
        onSaveFailed: console.error('Failed to save userStyles data')
    }
}
