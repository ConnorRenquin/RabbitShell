pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    property var config: {
        "wallpaperDirectory": "",
        "transition": "fade",
        "transitionDuration": 2
    }

    // readonly property string wallpaperDirectory: "/home/connor/Pictures/wallpapers"
    readonly property string wallpaperDirectory: config["wallpaperDirectory"] ?? ""
    readonly property string transition: config["transition"] ?? "fade"
    readonly property int transitionDuration: config["transitionDuration"] ?? 2

    function setWallpaperDirectory(path) {
        var newConfig = Object.assign({}, config);
        newConfig["wallpaperDirectory"] = path;
        config = newConfig;
    }

    function setTransition(trans) {
        var newConfig = Object.assign({}, config);
        newConfig["transition"] = trans;
        config = newConfig;
    }

    function setTransitionDuration(duration) {
        var newConfig = Object.assign({}, config);
        newConfig["transitionDuration"] = duration;
        config = newConfig;
    }

    onConfigChanged: {
        console.log('hi');
       if (persistantData.loaded) {
            console.log('saved');
            persistantData.setText(JSON.stringify(root.config));
        }
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/wallpaper-settings.json')
        blockLoading: false
        onLoaded: {
            try {
                root.config = JSON.parse(persistantData.text());
            } catch (e) {
                console.error('Failed to parse wallpaper settings data:', e);
                root.config = root.config;
            }
        }
        onLoadFailed: {
            Quickshell.execDetached(['touch', '.data/wallpaper-settings.json']);
            persistantData.setText(JSON.stringify(root.config));
        }
        onSaveFailed: console.error('Failed to save wallpaper settings data')
    }
}
