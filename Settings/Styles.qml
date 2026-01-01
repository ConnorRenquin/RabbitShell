pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    property var userStyles: {
        "Font Family": "RobotoMono Nerd Font Propo",
        "Margin Small": 10,
        "Margin Medium": 20,
        "Margin Large": 30,
        "Radius Small": 5,
        "Radius Medium": 10,
        "Radius Large": 15,
        "Text Extra Small": 12,
        "Text Small": 18,
        "Text Medium": 20,
        "Text Large": 26
    }

    readonly property string defaultFontFamily: userStyles["Font Family"] ?? "RobotoMono Nerd Font Propo"
    readonly property int barTextOffset: 2
    readonly property int marginSm: userStyles["Margin Small"] ?? 10
    readonly property int marginMd: userStyles["Margin Medium"] ?? 20
    readonly property int marginLg: userStyles["Margin Large"] ?? 30
    readonly property int radiusSm: userStyles["Radius Small"] ?? 5
    readonly property int radiusMd: userStyles["Radius Medium"] ?? 10
    readonly property int radiusLg: userStyles["Radius Large"] ?? 15
    readonly property int textLg: userStyles["Text Large"] ?? 26
    readonly property int textMd: userStyles["Text Medium"] ?? 20
    readonly property int textSm: userStyles["Text Small"] ?? 18
    readonly property int textXS: userStyles["Text Extra Small"] ?? 12

    onUserStylesChanged: {
        if (persistantData.loaded) {
            console.log('changed');
            persistantData.setText(JSON.stringify(root.userStyles));
        }
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/user-styles.json')
        blockLoading: false
        onLoaded: {
            try {
                console.log(root.userStyles["Margin Small"]);
                root.userStyles = JSON.parse(persistantData.text());
                console.log(root.userStyles["Margin Small"]);
            } catch (e) {
                console.log('Failed to parse userStyles data:', e);
                root.userStyles = root.userStyles;
            }
        }
        onLoadFailed: {
            Quickshell.execDetached(['touch', '.data/userStyles.json']);
            persistantData.setText(JSON.stringify(root.userStyles));
        }
        onSaveFailed: console.log('Failed to save userStyles data')
    }
}
