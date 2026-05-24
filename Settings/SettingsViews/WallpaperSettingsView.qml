pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.folderlistmodel

import qs.Settings
import qs.Settings.SettingsViews.Components
import qs.Components

Rectangle {
    id: root

    anchors.fill: parent
    color: Qt.lighter(Colors.surface, Colors.lighter)

    property string wallpaperDirectory
    property string wallpaperTransition
    property int wallpaperTransitionDuration

    Component.onCompleted: {
        root.wallpaperDirectory = Settings.register({
            name: 'wallpaperDirectory',
            value: '/home',
            category: 'wallpaper'
        }).value;
        root.wallpaperTransition = Settings.register({
            name: 'wallpaperTransition',
            value: 'fade',
            category: 'wallpaper'
        }).value;
        root.wallpaperTransitionDuration = Settings.register({
            name: 'wallpaperTransitionDuration',
            value: 5,
            category: 'wallpaper'
        }).value;
    }

    Connections {
        target: Settings
        function onSettingsChanged() {
            const s = Settings.settings;
            const dir = s.find(x => x.name === 'wallpaperDirectory');
            if (dir)
                root.wallpaperDirectory = dir.value;
            const transition = s.find(x => x.name === 'wallpaperTransition');
            if (transition)
                root.wallpaperTransition = transition.value;
            const duration = s.find(x => x.name === 'wallpaperTransitionDuration');
            if (duration)
                root.wallpaperTransitionDuration = duration.value;
        }
    }

    function setWallpaper(imagePath) {
        Quickshell.execDetached(["awww", "img", imagePath, "--transition-type", root.wallpaperTransition, "--transition-duration", root.wallpaperTransitionDuration.toString()]);
    }

    FolderListModel {
        id: folderModel
        folder: root.wallpaperDirectory ? "file://" + root.wallpaperDirectory : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.JPG", "*.JPEG", "*.PNG"]
        showDirs: false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginMd

        SettingsViewTitle {
            id: viewTitle
            title: "Wallpaper"
        }

        Rectangle {
            id: wallpaperDirectory
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: Colors.surface
            radius: Styles.radiusSm
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginMd
                spacing: Styles.marginSm

                TextStyled {
                    text: "Wallpaper Directory"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.marginSm

                    TextFieldStyled {
                        id: directoryField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        text: root.wallpaperDirectory
                        placeholderText: "Enter wallpaper directory path..."
                    }

                    ButtonStyled {
                        text: "Browse"
                        onClicked: zenityProcess.running = true
                    }

                    ButtonStyled {
                        text: "Apply"
                        onClicked: {
                            if (directoryField.text) {
                                Settings.change({
                                    name: 'wallpaperDirectory',
                                    value: directoryField.text
                                });
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: transitionsSection

            Layout.fillWidth: true
            Layout.preferredHeight: things.implicitHeight + Styles.marginMd
            color: Colors.surface
            radius: Styles.radiusSm

            Flow {
                id: things
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginMd

                ColumnLayout {
                    // Layout.fillWidth: true
                    spacing: Styles.marginSm

                    TextStyled {
                        text: "Transition Type"
                    }

                    ComboBoxStyled {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ["fade", "wipe", "grow", "outer", "center", "simple"]
                        Component.onCompleted: currentIndex = model.indexOf(root.wallpaperTransition)

                        onCurrentTextChanged: {
                            if (currentText) {
                                Settings.change({
                                    name: 'wallpaperTransition',
                                    value: currentText
                                });
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 150
                    spacing: Styles.marginSm

                    TextStyled {
                        text: "Duration"
                    }

                    RowLayout {
                        spacing: Styles.marginSm

                        TextFieldStyled {
                            id: durationField
                            Layout.preferredWidth: 60
                            text: root.wallpaperTransitionDuration
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
                                    Settings.change({
                                        name: 'wallpaperTransitionDuration',
                                        value: duration
                                    });
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: Styles.marginSm

                    TextStyled {
                        text: "Contrast"
                    }

                    ComboBoxStyled {
                        id: matugenContrast
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ["-1", "0", "1"]
                        currentIndex: 1
                    }
                }

                ColumnLayout {
                    spacing: Styles.marginSm

                    TextStyled {
                        text: "Dominant Color"
                    }

                    ComboBoxStyled {
                        id: matugenDominantColor
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ["0", "1", "2", "3", "4"]
                        currentIndex: 1
                    }
                }

                ColumnLayout {
                    spacing: Styles.marginSm

                    TextStyled {
                        text: "Resize"
                    }

                    ComboBoxStyled {
                        id: matugenResize
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ['nearest', 'triangle', 'catmull-rom', 'gaussian', 'lanczos3']
                        currentIndex: 1
                    }
                }

                ColumnLayout {
                    spacing: Styles.marginSm

                    TextStyled {
                        text: "Type"
                    }

                    ComboBoxStyled {
                        id: matugenType
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 250
                        model: ['scheme-content', 'scheme-expressive', 'scheme-fidelity', 'scheme-fruit-salad', 'scheme-monochrome', 'scheme-neutral', 'scheme-rainbow', 'scheme-tonal-spot', 'scheme-vibrant']
                        currentIndex: 7
                    }
                }

                ColumnLayout {

                    Layout.preferredWidth: 50
                    spacing: Styles.marginSm

                    TextStyled {
                        Layout.fillWidth: true
                        text: "DarkMode"
                    }

                    SwitchStyled {
                        id: matugenDarkmode
                        Layout.fillWidth: true
                        checked: true
                    }
                }
            }
        }

        TextStyled {
            text: "Available Wallpapers"
        }

        Rectangle {
            id: wallpaperSelectionSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.surface
            radius: Styles.radiusSm
            ScrollView {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                contentWidth: availableWidth
                GridLayoutPlus {
                    columns: Math.floor(parent.width / 500)
                    columnSpacing: Styles.marginSm
                    rowSpacing: Styles.marginSm
                    anchors.left: parent.left
                    anchors.right: parent.right
                    model: folderModel
                    delegate: Rectangle {
                        id: wallpaperItem

                        required property string fileName
                        required property url fileUrl
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 300
                        color: Qt.lighter(Colors.surface, Colors.lighter)
                        radius: Styles.radiusSm

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Styles.marginSm
                            spacing: Styles.marginSm

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: Qt.lighter(Colors.surface, Colors.lighter)
                                radius: Styles.radiusSm
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: wallpaperItem.fileUrl
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    TextStyled {
                                        anchors.centerIn: parent
                                        text: "Loading..."
                                        visible: parent.status === Image.Loading
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

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Styles.marginSm
                                TextStyled {
                                    Layout.maximumWidth: 200
                                    text: wallpaperItem.fileName
                                    font.pointSize: Styles.textSm
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                ButtonStyled {
                                    text: "󰉦 Generate Theme"
                                    Layout.fillWidth: true
                                    onClicked: {
                                        matugenProcess.path = wallpaperItem.fileUrl.toString().replace("file://", "");
                                        matugenProcess.running = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: noWallpaperPlaceholder
                anchors.centerIn: parent
                visible: folderModel.count === 0
                spacing: Styles.marginSm

                TextStyled {
                    text: root.wallpaperDirectory ? "No wallpapers found" : "Select a directory"
                    font.pointSize: Styles.textLg
                    Layout.alignment: Qt.AlignHCenter
                }

                TextStyled {
                    text: root.wallpaperDirectory ? "Check if the directory contains image files" : "Click 'Browse' or enter a path above"
                    font.pointSize: Styles.textSm
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

    Process {
        id: matugenProcess
        command: ['bash', '-c', 'matugen image ' + path + ' -m ' + mode + ' --contrast ' + contrast + ' --type ' + type + ' -r ' + resize + ' --source-color-index ' + dominantColor]

        property string path
        property string mode: matugenDarkmode.checked ? 'dark' : 'light'
        property string contrast: matugenContrast.currentText
        property string type: matugenType.currentText
        property string resize: matugenResize.currentText
        property string dominantColor: matugenDominantColor.currentText

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && path) {
                Settings.change({
                    name: 'currentTheme',
                    value: 'matugen.json'
                });
                Colors.reloadTheme();
                Colors.refreshThemes();
            }
        }
    }
}
