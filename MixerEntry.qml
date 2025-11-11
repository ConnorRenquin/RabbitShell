import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire

import qs.Components
import qs.Constants

Rectangle {
    id: root

    height: menu.implicitHeight + Styles.margin * 2
    required property PwNode node

    clip: true

    color: Colors.bg0
    radius: 10

    PwObjectTracker {
        objects: [node]
    }

    ColumnLayout {
        id: menu
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Styles.margin
        width: parent.width - Styles.margin * 2

        TextStyled {
            width: parent.width - Styles.margin * 2
            text: {
                const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
                const media = node.properties["media.name"];
                return media != undefined ? `${app} - ${media}` : app;
            }
            elide: Text.ElideRight
        }

        RowLayout {
            width: parent.width

            Rectangle {
                width: 15 + Styles.margin * 2
                height: 15 + Styles.margin * 2
                radius: 20
                color: mouseArea.containsMouse ? Colors.bg2 : Colors.bg2

                Behavior on color {
                    ColorAnimation {
                        duration: 250
                    }
                }

                TextStyled {
                    anchors.centerIn: parent
                    text: node.audio.muted ? "" : ""
                }

                MouseArea {
                    id: mouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: node.audio.muted = !node.audio.muted
                }
            }

            TextStyled {
                Layout.preferredWidth: 60
                horizontalAlignment: Text.Center
                text: `${Math.floor(node.audio.volume * 100)}%`
            }

            Slider {
                Layout.fillWidth: true
                value: node.audio.volume
                onValueChanged: node.audio.volume = value
            }
        }
    }
}
