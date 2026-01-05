pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.folderlistmodel

import Quickshell
import Quickshell.Io

import qs.Settings
import qs.Components

Rectangle {
    id: root

    anchors.fill: parent
    color: Colors.backgroundLifted

    FolderListModel {
        id: folderModel
        folder: WallpaperSettings.wallpaperDirectory ? "file://" + WallpaperSettings.wallpaperDirectory : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp", "*.JPG", "*.JPEG", "*.PNG"]
        showDirs: false
    }

    function setWallpaper(imagePath) {
        Quickshell.execDetached(["swww", "img", imagePath, "--transition-type", WallpaperSettings.transition, "--transition-duration", WallpaperSettings.transitionDuration.toString()]);
        WallpaperSettings.setCurrentWallpaper(imagePath);
    }

    function isImageFile(filename) {
        var lowerName = filename.toLowerCase();
        return lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg") || lowerName.endsWith(".png") || lowerName.endsWith(".bmp") || lowerName.endsWith(".gif") || lowerName.endsWith(".webp");
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginMd
        spacing: Styles.marginMd

        // Header
        TextStyled {
            text: "Wallpaper Settings"
            font.pixelSize: Styles.textLg
            Layout.fillWidth: true
        }

        // Directory Selection
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: Colors.background
            radius: Styles.radiusSm

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginMd
                spacing: Styles.marginSm

                TextStyled {
                    text: "Wallpaper Directory"
                    font.pixelSize: Styles.textMd
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.marginSm

                    TextFieldStyled {
                        id: directoryField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        text: WallpaperSettings.wallpaperDirectory
                        placeholderText: "Enter wallpaper directory path..."
                    }

                    ButtonStyled {
                        text: "Browse"
                        Layout.preferredHeight: 35
                        onClicked: zenityProcess.running = true
                    }

                    ButtonStyled {
                        text: "Apply"
                        Layout.preferredHeight: 35
                        onClicked: {
                            if (directoryField.text) {
                                WallpaperSettings.setWallpaperDirectory(directoryField.text);
                                folderModel.folder = "file://" + directoryField.text;
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: Colors.background
            radius: Styles.radiusSm

            RowLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginMd

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Styles.marginSm

                    TextStyled {
                        text: "Transition Type"
                        font.pixelSize: Styles.textSm
                    }

                    ComboBoxStyled {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ["fade", "wipe", "grow", "outer", "center", "simple"]
                        Component.onCompleted: {
                            currentIndex = model.indexOf(WallpaperSettings.transition);
                        }
                        onCurrentTextChanged: {
                            if (currentText) {
                                WallpaperSettings.setTransition(currentText);
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 200
                    spacing: Styles.marginSm

                    TextStyled {
                        text: "Duration (seconds)"
                        font.pixelSize: Styles.textSm
                    }

                    RowLayout {
                        spacing: Styles.marginSm

                        TextFieldStyled {
                            id: durationField
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 30
                            text: WallpaperSettings.transitionDuration.toString()
                            validator: IntValidator {
                                bottom: 1
                                top: 10
                            }
                        }

                        ButtonStyled {
                            text: "Set"
                            Layout.preferredHeight: 30
                            onClicked: {
                                var duration = parseInt(durationField.text);
                                if (duration >= 1 && duration <= 10) {
                                    WallpaperSettings.setTransitionDuration(duration);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Current Wallpaper Info
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Colors.background
            radius: Styles.radiusSm
            visible: WallpaperSettings.currentWallpaper

            RowLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                TextStyled {
                    text: "Current:"
                    font.pixelSize: Styles.textSm
                }

                TextStyled {
                    text: WallpaperSettings.currentWallpaper
                    font.pixelSize: Styles.textSm
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
            }
        }

        // Wallpaper Grid
        TextStyled {
            text: "Available Wallpapers"
            font.pixelSize: Styles.textMd
            visible: folderModel.count > 0
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.background
            radius: Styles.radiusSm

            ScrollView {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                contentWidth: availableWidth
                clip: true

                GridLayout {
                    columns: 3
                    columnSpacing: Styles.marginSm
                    rowSpacing: Styles.marginSm
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Repeater {
                        model: folderModel
                        delegate: Rectangle {
                            id: wallpaperItem
                            required property string fileName
                            required property url fileUrl
                            required property int index

                            Layout.preferredWidth: 210
                            Layout.preferredHeight: 170
                            color: Colors.backgroundLifted
                            radius: Styles.radiusSm

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Styles.marginSm
                                spacing: Styles.marginSm

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: Colors.backgroundLifted
                                    radius: Styles.radiusSm
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: wallpaperItem.fileUrl
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: false

                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                            border.width: WallpaperSettings.currentWallpaper === wallpaperItem.fileUrl.toString().replace("file://", "") ? 3 : 0
                                            border.color: Colors.foreground
                                            radius: Styles.radiusSm
                                        }

                                        BusyIndicator {
                                            anchors.centerIn: parent
                                            running: parent.status === Image.Loading
                                            visible: running
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var path = wallpaperItem.fileUrl.toString().replace("file://", "");
                                            root.setWallpaper(path);
                                        }
                                    }
                                }

                                TextStyled {
                                    text: wallpaperItem.fileName
                                    font.pixelSize: Styles.textXS
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            // Placeholder when no wallpapers
            ColumnLayout {
                anchors.centerIn: parent
                visible: folderModel.count === 0
                spacing: Styles.marginSm

                TextStyled {
                    text: WallpaperSettings.wallpaperDirectory ? "No wallpapers found" : "Select a directory"
                    font.pixelSize: Styles.textLg
                    Layout.alignment: Qt.AlignHCenter
                }

                TextStyled {
                    text: WallpaperSettings.wallpaperDirectory ? "Check if the directory contains image files" : "Click 'Browse' or enter a path above"
                    font.pixelSize: Styles.textSm
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    Process {
        id: zenityProcess
        running: false
        command: ["zenity", "--file-selection", "--directory", "--title=Select Wallpaper Directory"]
        stdout: StdioCollector {
            onStreamFinished: {
                var path = this.text.trim();
                if (path) {
                    directoryField.text = path;
                }
            }
        }
    }
}
