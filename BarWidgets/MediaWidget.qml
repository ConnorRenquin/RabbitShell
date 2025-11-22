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

    component ButtonStyledLocal: ButtonStyled {
        id: buttonLocal

        property string iconText: ""
        property color iconColor: Colors.bgDim
        property color backgroundColor: Colors.green

        width: iconTextItem.width + Styles.marginSm * 2
        height: root.height - Styles.marginSm
        radius: Styles.radiusSm
        defaultColor: backgroundColor
        anchors.verticalCenter: parent.verticalCenter

        TextStyled {
            id: iconTextItem
            color: iconColor
            anchors.centerIn: parent
            text: buttonLocal.iconText
        }
    }

    PopupWindow {
        visible: albumArtMouse.containsMouse
        width: 400
        height: 400

        color: "transparent"

        anchor {
            item: albumArt
            rect.x: albumArt.x - root.width
            rect.y: albumArt.height + Styles.marginSm
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
        ButtonStyledLocal {
            iconText: "󰒮"
            onClicked: root.player.previous()
        }
        ButtonStyledLocal {
            backgroundColor: root.player.isPlaying ? Colors.orange : Colors.bg1
            iconColor: root.player.isPlaying ? Colors.bgDim : Colors.fg
            iconText: "󰐎"
            onClicked: root.player.togglePlaying()
        }
        ButtonStyledLocal {
            iconText: "󰒭"
            onClicked: root.player.next()
        }
    }
}
