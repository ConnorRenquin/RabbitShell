pragma ComponentBehavior: Bound

import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components

Rectangle {
    id: root

    anchors.fill: parent
    color: Colors.backgroundLifted

    property string pendingThemeName: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginMd
        spacing: Styles.marginMd

        TextStyled {
            id: viewTitle
            text: "Wallpaper"
            font.pixelSize: Styles.textLg
            Layout.fillWidth: true
        }

        Rectangle {
            id: wallpaperDirectory
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
                        onClicked: zenityProcess.running = true
                    }

                    ButtonStyled {
                        text: "Apply"
                        onClicked: {
                            if (directoryField.text) {
                                WallpaperSettings.setWallpaperDirectory(directoryField.text);
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: transitionsSection

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
                    }

                    ComboBoxStyled {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: ["fade", "wipe", "grow", "outer", "center", "simple"]
                        Component.onCompleted: currentIndex = model.indexOf(WallpaperSettings.transition)

                        onCurrentTextChanged: {
                            if (currentText) {
                                WallpaperSettings.setTransition(currentText);
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

                RowLayout {
                    Layout.preferredWidth: 300
                    spacing: Styles.marginMd
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
                            Layout.preferredWidth: 100
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

        }

        TextStyled {
            text: "Available Wallpapers"
        }

        Rectangle {
            id: wallpaperSelectionSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.background
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
                    model: WallpaperSettings.folderModel
                    delegate: Rectangle {
                        id: wallpaperItem

                        required property string fileName
                        required property url fileUrl
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 300
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
                                        WallpaperSettings.setWallpaper(path);
                                    }
                                }
                            }


                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Styles.marginSm
                                TextStyled {
                                    Layout.maximumWidth: 200
                                    text: wallpaperItem.fileName
                                    font.pixelSize: Styles.textSm
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

            // Placeholder when no wallpapers
            ColumnLayout {
                anchors.centerIn: parent
                visible: WallpaperSettings.folderModel.count === 0
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

    Process {
        id: matugenProcess
        command: ['bash', '-c', 'matugen image ' + path + ' -m ' + mode + ' --contrast ' + contrast + ' --type ' + type + ' -r ' + resize]

        property string path
        property string mode: matugenDarkmode.checked ? 'dark' : 'light'
        property string contrast: matugenContrast.currentText
        property string type: matugenType.currentText
        property string resize: matugenResize.currentText

        onRunningChanged: {
            console.log(command)
            if (!running && path) {
                GlobalSettings.currentTheme = ''
                GlobalSettings.currentTheme = 'matugen.json'
            }
        }
    }
}
