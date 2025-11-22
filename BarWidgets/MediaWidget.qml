import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick

import qs.Components
import qs.Constants

Rectangle {
    id: root
    width: row.implicitWidth + Styles.marginMd
    height: parent.height
    color: Colors.bgDim
    radius: Styles.radiusSm
    visible: root.player !== null

    property MprisPlayer player: Mpris.players.values.filter(player => player.identity === "Spotify")[0] || null

    PopupWindow {
        visible: albumArtMouse.containsMouse
        width: 400
        height: 400
        color: "transparent"
        anchor {
            item: albumArt
            rect {
                x: albumArt.x - root.width
                y: albumArt.height + Styles.marginMd
            }
        }

        ClippingRectangle {
            anchors.fill: parent
            radius: Styles.radiusLg
            Image {
                z: 0
                anchors.fill: parent
                source: root.player !== null ? root.player.trackArtUrl : ""
            }

            Rectangle {
                z: 1
                color: Colors.bgDim
                implicitHeight: popupText.implicitHeight * 2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.horizontalCenter: parent.horizontalCenter
                DoubleText {
                    id: popupText
                    anchors.centerIn: parent
                    pixelSize: Styles.textMd
                    offset: 4
                    text: root.player?.trackTitle + " - " + root.player?.trackArtist
                }
            }
        }
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.margins: Styles.marginSm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Styles.marginSm
        ClippingRectangle {
            id: albumArt
            z: 0
            width: root.height
            height: root.height
            radius: Styles.radiusMd
            Image {
                width: root.height
                height: root.height
                source: root.player !== null ? root.player.trackArtUrl : ""
            }
            MouseArea {
                id: albumArtMouse
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        ButtonStyled {
            width: prev.width + Styles.marginSm * 2
            height: root.height - Styles.marginSm
            radius: Styles.radiusSm
            defaultColor: Colors.green
            anchors.verticalCenter: parent.verticalCenter
            TextStyled {
                id: prev
                color: Colors.bgDim
                anchors.centerIn: parent
                text: "󰒮"
            }
            onClicked: root.player.previous()
        }
        ButtonStyled {
            width: next.width + Styles.marginSm * 2
            height: root.height - Styles.marginSm
            anchors.verticalCenter: parent.verticalCenter
            defaultColor: root.player.isPlaying ? Colors.orange : Colors.bg1
            radius: Styles.radiusSm
            TextStyled {
                id: play
                anchors.centerIn: parent
                color: root.player.isPlaying ? Colors.bgDim : Colors.fg
                text: "󰐎"
            }
            onClicked: root.player.togglePlaying()
        }
        ButtonStyled {
            width: next.width + Styles.marginSm * 2
            height: root.height - Styles.marginSm
            defaultColor: Colors.green
            radius: Styles.radiusSm
            anchors.verticalCenter: parent.verticalCenter
            TextStyled {
                id: next
                color: Colors.bgDim
                anchors.centerIn: parent
                text: "󰒭"
            }
            onClicked: root.player.next()
        }
    }
}
