pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Hyprland

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

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

        anchors.top: true
        margins.top: 60

        implicitWidth: 650
        implicitHeight: Math.min(300, mixerList.implicitHeight + Styles.marginSm * 2)
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

            // TODO Make layoutViewsWrappers
            // Keys.onPressed: event => {
            //     if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
            //         loader.active = false;
            //     } else if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
            //         mixerList.incrementCurrentIndex();
            //     } else if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
            //         mixerList.decrementCurrentIndex();
            //     } else if ([Qt.Key_Left, Qt.Key_H].includes(event.key)) {
            //         if (mixerList.currentItem && mixerList.currentItem.modelData) {
            //             const newVolume = Math.max(0, mixerList.currentItem.modelData.volume - 0.05);
            //             mixerList.currentItem.modelData.setVolume(newVolume);
            //         }
            //     } else if ([Qt.Key_Right, Qt.Key_L].includes(event.key)) {
            //         if (mixerList.currentItem && mixerList.currentItem.modelData) {
            //             const newVolume = Math.min(1, mixerList.currentItem.modelData.volume + 0.05);
            //             mixerList.currentItem.modelData.setVolume(newVolume);
            //         }
            //     } else if ([Qt.Key_M].includes(event.key)) {
            //         if (mixerList.currentItem && mixerList.currentItem.modelData) {
            //             mixerList.currentItem.modelData.setMuted(!mixerList.currentItem.modelData.muted);
            //         }
            //     }
            // }

            ScrollView {
                anchors.fill: parent
                ColumnLayoutPlus {
                    id: mixerList
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm
                    model: Object.values(Audio.nodeStates)
                    delegate: Rectangle {
                        id: mixerEntry
                        required property var index
                        required property AudioNodeState modelData
                        property PwNode node: modelData.node

                        Layout.fillWidth: true
                        Layout.preferredHeight: 100

                        color: ListView.isCurrentItem ? Colors.backgroundLifted : Colors.background
                        radius: Styles.radiusSm
                        focus: true

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
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
                                    source: Quickshell.iconPath(mixerEntry.node.name, "audio-volume-high-symbolic")
                                    implicitWidth: 40
                                    implicitHeight: 40
                                }

                                TextStyled {
                                    Layout.fillWidth: true
                                    text: mixerEntry.modelData.getName()
                                }
                            }

                            RowLayout {
                                id: controlRow
                                Layout.fillWidth: true
                                Layout.leftMargin: Styles.marginSm
                                Layout.rightMargin: Styles.marginSm

                                ButtonStyled {
                                    id: muteButton
                                    implicitWidth: 40
                                    implicitHeight: muteIcon.implicitHeight + Styles.marginSm
                                    radius: 100
                                    defaultColor: mixerEntry.modelData?.muted ? Colors.background : Colors.foreground
                                    onClicked: mixerEntry.modelData.setMuted(!mixerEntry.modelData.muted)
                                    TextStyled {
                                        id: muteIcon
                                        anchors.centerIn: parent
                                        font.pixelSize: Styles.textSm
                                        color: mixerEntry.modelData?.muted ? Colors.foreground : Colors.background
                                        text: mixerEntry.modelData?.muted ? "" : ""
                                    }
                                }

                                VolumeSlider {
                                    Layout.fillWidth: true
                                    modelData: mixerEntry.modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
