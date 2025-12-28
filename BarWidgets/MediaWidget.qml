pragma ComponentBehavior: Bound
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
    color: Colors.backgroundDim
    radius: Styles.radiusSm
    visible: root.player !== null

    property MprisPlayer player: Mpris.players.values.filter(player => player.identity === "Spotify")[0] || null

    component ButtonStyledLocal: ButtonStyled {
        id: buttonLocal

        property string iconText: ""
        property string iconColor: Colors.backgroundDim
        property string backgroundColor: Colors.green

        width: iconTextItem.width + Styles.marginSm * 2
        height: root.height - Styles.marginSm
        radius: Styles.radiusSm
        defaultColor: backgroundColor
        anchors.verticalCenter: parent.verticalCenter

        TextStyled {
            id: iconTextItem
            color: buttonLocal.iconColor
            anchors.centerIn: parent
            text: buttonLocal.iconText
        }
    }

    PopupWindowAnimated {
        id: popup
        implicitWidth: 400
        implicitHeight: 400

        anchor {
            item: albumArt
            rect.x: albumArt.x - root.width
            rect.y: albumArt.height + Styles.marginSm
        }

        Connections {
            target: albumArtMouse
            function onContainsMouseChanged() {
                if (albumArtMouse.containsMouse) {
                    popup.show();
                } else {
                    popup.hide();
                }
            }
        }

        ClippingRectangle {
            radius: Styles.radiusLg
            height: parent.height
            width: parent.width

            opacity: popup.isOpen ? 1 : 0
            scale: popup.isOpen ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing: Easing.InOutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                }
            }

            Image {
                z: 0
                anchors.fill: parent
                source: root.player !== null ? root.player.trackArtUrl : ""
            }

            Rectangle {
                z: 1
                color: Colors.backgroundDim
                implicitHeight: popupText.implicitHeight * 2
                anchors.left: parent.left
                anchors.right: parent.right
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
            backgroundColor: root.player?.isPlaying ? Colors.orange : Colors.bg1
            iconColor: root.player?.isPlaying ? Colors.backgroundDim : Colors.foreground
            iconText: "󰐎"
            onClicked: root.player.togglePlaying()
        }
        ButtonStyledLocal {
            iconText: "󰒭"
            onClicked: root.player.next()
        }
    }
}
