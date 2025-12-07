import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.Components
import qs.Constants

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore

    anchors.right: true
    margins.right: Styles.marginMd

    implicitWidth: 650
    implicitHeight: column.implicitHeight + Styles.marginSm * 2
    color: "transparent"
    visible: false

    GlobalShortcut {
        name: "mixer"
        onPressed: root.visible = !root.visible
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
        onCleared: root.visible = false
    }

    Rectangle {
        id: base

        focus: true

        anchors.fill: parent

        color: Colors.bgDim
        radius: Styles.radiusSm

        property int currentIndex: 0

        Keys.onPressed: event => {
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.visible = false;
                event.accepted = true;
                return;
            }

            if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                moveFocusNext();
            }
            if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                moveFocusPrevious();
            }

            column.children[currentIndex].forceActiveFocus();
        }

        function moveFocusNext() {
            currentIndex = (base.currentIndex + 1) % column.children.length;
        }

        function moveFocusPrevious() {
            currentIndex = (base.currentIndex - 1 + column.children.length) % column.children.length;
        }

        Column {
            id: column

            spacing: Styles.marginSm

            anchors.fill: parent
            anchors.margins: Styles.marginSm

            PwNodeLinkTracker {
                id: linkTracker
                node: Pipewire?.defaultAudioSink
            }

            Repeater {
                model: linkTracker.linkGroups
                delegate: Rectangle {
                    id: mixerEntry

                    property PwNode node: modelData?.source ?? null

                    implicitHeight: 100
                    implicitWidth: 400

                    color: index === base.currentIndex ? Colors.bgGreen : Colors.bg0
                    radius: Styles.radiusSm
                    focus: true

                    anchors.left: parent.left
                    anchors.right: parent.right

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    Keys.onPressed: function (event) {
                        if ([Qt.Key_Left, Qt.Key_H].includes(event.key)) {
                            volumeSlider.decrease();
                        } else if ([Qt.Key_Right, Qt.Key_L].includes(event.key)) {
                            volumeSlider.increase();
                        } else if ([Qt.Key_M].includes(event.key)) {
                            node.audio.muted = !node?.audio?.muted;
                        }
                    }

                    PwObjectTracker {
                        id: tracker
                        objects: [node]
                    }

                    Item {
                        id: info

                        anchors {
                            left: parent.left
                            top: parent.top
                            right: parent.right
                            margins: Styles.marginSm
                        }

                        IconImage {
                            id: icon
                            source: Quickshell.iconPath(node.name).toLowerCase() ?? "audio-volume-high-symbolic"
                            implicitWidth: 32
                            implicitHeight: 32
                        }

                        TextStyled {
                            id: deviceName
                            text: node?.name
                            anchors {
                                left: icon.right
                                top: parent.top
                                right: parent.right
                                margins: Styles.marginSm
                            }
                        }
                    }

                    Item {
                        id: controls
                        height: 30

                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                            right: parent.right
                            margins: Styles.marginSm
                        }

                        ButtonStyled {
                            id: muteButton
                            implicitWidth: muteIcon.implicitWidth + Styles.marginLg
                            implicitHeight: muteIcon.implicitHeight + Styles.marginMd
                            radius: 100
                            defaultColor: node?.audio.muted ? Colors.bgDim : Colors.orange

                            anchors {
                                right: volumeSlider.left
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                                margins: Styles.marginSm
                            }

                            onClicked: node.audio.muted = !node?.audio.muted
                            TextStyled {
                                id: muteIcon
                                anchors.centerIn: parent
                                font.pixelSize: 12
                                color: node?.audio.muted ? Colors.orange : Colors.bgDim
                                text: node?.audio.muted ? "" : ""
                            }
                        }

                        // TODO Refact into StyledSlider
                        Slider {
                            id: volumeSlider
                            value: node.audio.volume
                            stepSize: 0.05

                            anchors {
                                right: parent.right
                                left: muteButton.right
                                verticalCenter: parent.verticalCenter
                                margins: Styles.marginSm
                            }

                            onValueChanged: node.audio.volume = value

                            // background: Rectangle {
                            //     x: volumeSlider.leftPadding
                            //     y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2

                            //     implicitWidth: 300
                            //     implicitHeight: 5

                            //     radius: Styles.margin
                            //     color: Colors.bgDim

                            //     Rectangle {
                            //         implicitWidth: volumeSlider.visualPosition * parent.width
                            //         implicitHeight: parent.height - Styles.marginSm
                            //         color: Colors.green
                            //         radius: Styles.margin
                            //     }
                            // }

                            handle: Rectangle {
                                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: textPercent.width + 16
                                implicitHeight: 16
                                radius: Styles.margin
                                color: mouseArea.containsMouse ? Colors.blue : Colors.green

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }

                                TextStyled {
                                    id: textPercent
                                    anchors.centerIn: parent
                                    color: Colors.bg1
                                    font.pixelSize: 12
                                    text: `${Math.floor(node?.audio.volume * 100)}%`
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
