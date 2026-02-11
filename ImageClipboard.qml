import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

import QtCore

import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel

import qs.Settings
import qs.Components

FloatingWindow {
    id: root
    visible: false
    title: "Image Clipboard"

    FolderListModel {
        id: folderModel
        folder: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/Pictures/clipboard"
        rootFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/Pictures/clipboard"
        sortReversed: true
        showDirs: false
    }

    GlobalShortcut {
        name: 'image-clipboard'
        onPressed: root.visible = !root.visible
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        ScrollViewPlus {
            id: scrollView
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            contentWidth: availableWidth
            GridLayoutPlus {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                columns: Math.floor(parent.width / 240)

                model: folderModel
                delegate: Rectangle {
                    id: image

                    required property string fileName
                    required property url fileUrl
                    required property int index

                    Layout.preferredHeight: 250
                    Layout.fillWidth: true
                    Layout.margins: Styles.marginSm / 2

                    color: "transparent"

                    ClippingRectangle {
                        anchors.fill: parent
                        radius: Styles.radiusSm
                        border.width: Styles.marginSm
                        border.color: Colors.backgroundLifted
                        color: Colors.backgroundLifted
                        Image {
                            id: imageComponent
                            anchors.fill: parent
                            source: image.fileUrl
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            cache: false

                            property int retryCount: 0
                            property int maxRetries: 5


                            onStatusChanged: {
                                if (status === Image.Error && retryCount < maxRetries) {
                                    retryTimer.start()
                                }
                            }

                            Timer {
                                id: retryTimer
                                interval: 500
                                repeat: false
                                onTriggered: {
                                    imageComponent.retryCount++
                                    var oldSource = imageComponent.source
                                    imageComponent.source = ""
                                    imageComponent.source = oldSource
                                }
                            }

                            LoadingIndicator {
                                font.pixelSize: Styles.textLg
                                anchors.centerIn: parent
                                visible: imageComponent.status === Image.Loading || imageComponent.status === Image.Error
                            }

                            ColumnLayout {
                                id: modificationButtons
                                height: 40
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: Styles.marginSm

                                ButtonStyled {
                                    id: editButton
                                    text: ""
                                    Layout.fillWidth: true
                                    onClicked: Quickshell.execDetached(['sh', '-c', 'satty --filename ' + String(image.fileUrl).replace('file://', '')])
                                }
                                ButtonStyled {
                                    id: copyButton
                                    text: ""
                                    Layout.fillWidth: true
                                    onClicked: Quickshell.execDetached(['sh', '-c', 'wl-copy --type image/png < ' + String(image.fileUrl).replace('file://', '')])
                                }
                                ButtonStyled {
                                    id: deleteButton
                                    text: ""
                                    Layout.fillWidth: true
                                    onClicked: Quickshell.execDetached(['sh', '-c', 'rm ' + String(image.fileUrl).replace('file://', '')])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
