import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import Quickshell.Hyprland

import qs.Components
import qs.Constants

Rectangle {
    id: root

    required property PwNode node

    height: menu.implicitHeight + Styles.margin * 2
    color: activeFocus ? Colors.bgGreen : Colors.bg0
    radius: Styles.radiusSm
    focus: true

    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }

    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Left) {
            volumeSlider.value = Math.max(0, volumeSlider.value - 0.05);
        } else if (event.key === Qt.Key_Right) {
            volumeSlider.value = Math.min(1.5, volumeSlider.value + 0.05);
        } else if (event.key === Qt.Key_M) {
            node.audio.muted = !node.audio.muted;
        }
    }

    PwObjectTracker {
        objects: [node]
    }

    ColumnLayout {
        id: menu
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Styles.margin
        width: parent.width - Styles.margin * 2

        // Title
        TextStyled {
            text: {
                const app = node.properties["media.name"] ?? "Speaker";
                return app;
            }
        }

        RowLayout {
            width: parent.width

            // Mute Button
            ButtonStyled {
                width: muteIcon.implicitWidth + Styles.marginMd
                height: muteIcon.implicitHeight + Styles.marginMd
                radius: 100

                defaultColor: node.audio.muted ? Colors.bgDim : Colors.orange
                TextStyled {
                    id: muteIcon
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    color: node.audio.muted ? Colors.orange : Colors.bgDim
                    text: node.audio.muted ? "" : ""
                }
                onClicked: node.audio.muted = !node.audio.muted
            }

            // TODO Refact into StyledSlider
            Slider {
                id: volumeSlider
                Layout.fillWidth: true
                value: node.audio.volume
                onValueChanged: node.audio.volume = value

                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: volumeSlider.availableWidth
                    height: implicitHeight
                    radius: Styles.margin
                    color: Colors.bgDim

                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        color: Colors.green
                        radius: Styles.margin
                    }
                }

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
                        text: `${Math.floor(node.audio.volume * 100)}%`
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
