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
            ColumnLayoutPlus {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
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
                        Image {
                            anchors.fill: parent
                            source: image.fileUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            ColumnLayout {
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
                            TextStyled {
                                anchors.centerIn: parent
                                text: "Loading..."
                                visible: parent.status === Image.Loading
                            }
                        }
                    }
                }
            }
        }
    }
}
