pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick
import Qt.labs.folderlistmodel

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

    property alias folderModel: folderModel

    FolderListModel {
        id: folderModel
        folder: root.wallpaperDirectory ? "file://" + root.wallpaperDirectory : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp", "*.JPG", "*.JPEG", "*.PNG"]
        showDirs: false
    }

    function setWallpaperDirectory(path) {
        var newConfig = Object.assign({}, config);
        newConfig["wallpaperDirectory"] = path;
        config = newConfig;
        folderModel.folder = path ? "file://" + path : "";
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

    function setWallpaper(imagePath) {
        Quickshell.execDetached(["swww", "img", imagePath, "--transition-type", root.transition, "--transition-duration", root.transitionDuration.toString()]);
    }

    function setRandomWallpaper() {
        if (folderModel.count === 0) {
            console.warn("No wallpapers available in directory");
            return;
        }

        var randomIndex = Math.floor(Math.random() * folderModel.count);
        var fileUrl = folderModel.get(randomIndex, "fileUrl");
        var filePath = fileUrl.toString().replace("file://", "");
        setWallpaper(filePath);
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
