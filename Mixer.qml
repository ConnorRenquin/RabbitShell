pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Hyprland

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Components
import qs.Constants

Loader {
    id: loader

    active: false

    GlobalShortcut {
        name: "mixer"
        onPressed: active = !active
    }

    sourceComponent: PanelWindow {
        id: root

        exclusionMode: ExclusionMode.Ignore

        anchors.right: true
        margins.right: Styles.marginMd

        implicitWidth: 650
        implicitHeight: mixerList.contentHeight + Styles.marginSm * 2
        color: "transparent"

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        Rectangle {
            id: base

            focus: true

            anchors.fill: parent

            color: Colors.background
            radius: Styles.radiusSm

            Keys.onPressed: event => {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    loader.active = false;
                } else if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                    mixerList.incrementCurrentIndex();
                } else if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                    mixerList.decrementCurrentIndex();
                } else if ([Qt.Key_Left, Qt.Key_H].includes(event.key)) {
                    if (mixerList.currentItem && mixerList.currentItem.node) {
                        mixerList.currentItem.node.audio.volume = Math.max(0, mixerList.currentItem.node.audio.volume - 0.05);
                    }
                } else if ([Qt.Key_Right, Qt.Key_L].includes(event.key)) {
                    if (mixerList.currentItem && mixerList.currentItem.node) {
                        mixerList.currentItem.node.audio.volume = Math.min(1, mixerList.currentItem.node.audio.volume + 0.05);
                    }
                } else if ([Qt.Key_M].includes(event.key)) {
                    if (mixerList.currentItem && mixerList.currentItem.node) {
                        mixerList.currentItem.node.audio.muted = !mixerList.currentItem.node.audio.muted;
                    }
                }
                mixerList.positionViewAtIndex(mixerList.currentIndex, ListView.Contain);
            }

            PwNodeLinkTracker {
                id: linkTracker
                node: Pipewire?.defaultAudioSink
            }

            ListView {
                id: mixerList

                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                model: linkTracker.linkGroups
                delegate: Rectangle {
                    id: mixerEntry
                    required property var modelData
                    required property var index

                    implicitHeight: mixerColum.implicitHeight + Styles.marginMd
                    width: mixerList.width

                    color: ListView.isCurrentItem ? Colors.backgroundSuccess : Colors.bg1
                    radius: Styles.radiusSm
                    focus: true

                    property PwNode node: modelData?.source ?? null

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    PwObjectTracker {
                        id: tracker
                        objects: [mixerEntry.node]
                    }

                    ColumnLayout {
                        id: mixerColum
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginLg

                        RowLayout {
                            id: info

                            spacing: Styles.marginSm

                            Layout.fillWidth: true
                            Layout.leftMargin: Styles.marginSm
                            Layout.rightMargin: Styles.marginSm
                            Layout.preferredHeight: 20

                            IconImage {
                                id: icon
                                source: Quickshell.iconPath(mixerEntry.node.name).toLowerCase() ?? "audio-volume-high-symbolic"
                                implicitWidth: 40
                                implicitHeight: 40
                            }

                            TextStyled {
                                text: mixerEntry.node?.name
                            }
                        }

                        RowLayout {
                            id: controlRow
                            Layout.fillWidth: true
                            Layout.leftMargin: Styles.marginSm
                            Layout.rightMargin: Styles.marginSm

                            ButtonStyled {
                                id: muteButton
                                implicitWidth: muteIcon.implicitWidth + Styles.marginLg
                                implicitHeight: muteIcon.implicitHeight + Styles.marginSm
                                radius: 100
                                defaultColor: mixerEntry.node?.audio.muted ? Colors.background : Colors.orange

                                onClicked: mixerEntry.node.audio.muted = !mixerEntry.node?.audio.muted
                                TextStyled {
                                    id: muteIcon
                                    anchors.centerIn: parent
                                    font.pixelSize: 14
                                    color: mixerEntry.node?.audio.muted ? Colors.orange : Colors.background
                                    text: mixerEntry.node?.audio.muted ? "" : ""
                                }
                            }

                            // TODO Refact into StyledSlider
                            Slider {
                                id: volumeSlider
                                value: mixerEntry.node.audio.volume
                                stepSize: 0.05
                                Layout.fillWidth: true

                                onValueChanged: mixerEntry.node.audio.volume = value

                                background: Rectangle {
                                    x: volumeSlider.leftPadding
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2

                                    implicitWidth: 100

                                    radius: Styles.radiusSm
                                    color: Colors.background

                                    Rectangle {
                                        implicitWidth: volumeSlider.visualPosition * parent.width
                                        implicitHeight: parent.height
                                        color: Colors.green
                                        radius: Styles.radiusSm
                                    }
                                }

                                handle: Rectangle {
                                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2

                                    implicitWidth: textPercent.width + Styles.marginSm
                                    implicitHeight: muteButton.implicitHeight

                                    radius: Styles.radiusSm
                                    color: mouseArea.containsMouse ? Colors.blue : Colors.orange

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }

                                    TextStyled {
                                        id: textPercent
                                        anchors.centerIn: parent
                                        color: Colors.bg1
                                        font.pixelSize: 14
                                        text: `${Math.floor(mixerEntry.node?.audio.volume * 100)}%`
                                    }
                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.NoButton
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
