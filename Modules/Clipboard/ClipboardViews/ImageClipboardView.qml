import Quickshell
import Quickshell.Widgets

import QtCore as QtCoreLib

import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel

import qs.Settings
import qs.Helpers
import qs.Components
import qs.Components.Plus
import qs.Components.Styled
import qs.Services

Rectangle {
    id: root
    color: "transparent"
    focus: isActive

    Themer {
        id: theme
        variant: 'regular'

        Component.onCompleted: {
            const s = Settings.get('clipboardColor');
            if (s) variant = s.value;
        }

        Connections {
            target: Settings
            function onSettingsChanged() {
                const s = Settings.settings.find(x => x.name === 'clipboardColor');
                if (s) theme.variant = s.value;
            }
        }
    }

    visible: isActive
    property bool isActive: false

    FolderListModel {
        id: folderModel
        folder: QtCoreLib.StandardPaths.writableLocation(QtCoreLib.StandardPaths.HomeLocation) + "/Pictures/clipboard"
        rootFolder: QtCoreLib.StandardPaths.writableLocation(QtCoreLib.StandardPaths.HomeLocation) + "/Pictures/clipboard"
        sortReversed: true
        showDirs: false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Styles.marginSm

        ScrollViewPlus {
            id: scrollView
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Styles.marginSm

            contentWidth: availableWidth

            Flow {
                id: flow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Styles.marginSm

                Repeater {
                    model: folderModel

                    Rectangle {
                        id: image

                        required property string fileName
                        required property url fileUrl
                        required property int index

                        height: 250
                        width: imageComponent.status === Image.Ready ? Math.round(250 * imageComponent.implicitWidth / imageComponent.implicitHeight) : 200

                        Behavior on width {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }
                        }

                        color: "transparent"

                        ClippingRectangle {
                            anchors.fill: parent
                            radius: Styles.radiusSm
                            color: theme.foreground

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
                                        retryTimer.start();
                                    }
                                }

                                Timer {
                                    id: retryTimer
                                    interval: 500
                                    repeat: false
                                    onTriggered: {
                                        imageComponent.retryCount++;
                                        var oldSource = imageComponent.source;
                                        imageComponent.source = "";
                                        imageComponent.source = oldSource;
                                    }
                                }

                                LoadingIndicator {
                                    font.pointSize: Styles.textLg
                                    anchors.centerIn: parent
                                    visible: imageComponent.status === Image.Loading || imageComponent.status === Image.Error
                                }

                                ColumnLayout {
                                    id: modificationButtons
                                    height: 40
                                    width: 40
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: Styles.marginSm

                                    LocalButton {
                                        id: editButton
                                        text: Icons.edit
                                        onClicked: Quickshell.execDetached(['sh', '-c', 'satty --filename ' + String(image.fileUrl).replace('file://', '')])
                                    }
                                    LocalButton {
                                        id: copyButton
                                        text: Icons.copy
                                        onClicked: Quickshell.execDetached(['sh', '-c', 'wl-copy --type image/png < ' + String(image.fileUrl).replace('file://', '')])
                                    }
                                    LocalButton {
                                        id: deleteButton
                                        text: Icons.trash
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

    component LocalButton: ButtonStyled {
        Layout.fillWidth: true
        defaultColor: theme.text
        textColor: theme.background
    }
}
