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
                delegate: ButtonStyled {
                    id: image
                    required property string fileName
                    required property url fileUrl
                    required property int index
                    Layout.preferredHeight: 250
                    Layout.fillWidth: true
                    Layout.margins: Styles.marginSm / 2

                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            Quickshell.execDetached(['sh', '-c', 'rm ' + String(fileUrl).replace('file://', '')]);
                        } else {
                            Quickshell.execDetached(['sh', '-c', 'wl-copy --type image/png < ' + String(fileUrl).replace('file://', '')]);
                        }
                    }

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
