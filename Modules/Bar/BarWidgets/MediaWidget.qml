pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Components.Styled
import qs.Settings
import qs.Services
import qs.Helpers

Rectangle {
    id: root
    Layout.preferredWidth: row.implicitWidth + Styles.marginMd
    color: Colors.surface
    radius: Styles.radiusSm
    visible: root.player !== null

    property MprisPlayer player: Mpris.players.values.filter(player => player.identity === "Spotify")[0] || null

    Themer { id: theme }

    component ButtonStyledLocal: ButtonStyled {
        id: buttonLocal

        property string iconText: ""
        property string iconColor: Colors.surface
        property string backgroundColor: theme.text

        implicitWidth: iconTextItem.width + Styles.marginSm * 2
        implicitHeight: root.height - Styles.marginSm

        defaultColor: backgroundColor
        anchors.verticalCenter: parent.verticalCenter

        TextStyled {
            id: iconTextItem
            color: buttonLocal.iconColor
            anchors.centerIn: parent
            text: buttonLocal.iconText
        }
    }

    PopupWindow {
        id: popup
        implicitWidth: 400
        visible: albumArtMouse.containsMouse
        implicitHeight: 400
        color: "transparent"

        property bool topBarSetting: Settings.get('barPosition').value
        property var yValue: topBarSetting ? albumArt.height + Styles.marginSm : -430

        anchor {
            item: albumArt
            rect.x: albumArt.x - root.width
            rect.y: yValue
        }

        ClippingRectangle {
            radius: Styles.radiusLg
            height: parent.height
            width: parent.width

            opacity: popup.visible ? 1 : 0
            scale: popup.visible ? 1 : 0

            NumberAnimation on opacity {
                duration: 200
            }

            NumberAnimation on scale {
                duration: 200
            }

            Image {
                z: 0
                anchors.fill: parent
                source: root.player !== null ? root.player.trackArtUrl : ""
            }

            Rectangle {
                z: 1
                color: Colors.surface
                implicitHeight: popupText.implicitHeight * 2
                anchors.left: parent.left
                anchors.right: parent.right
                DoubleText {
                    id: popupText
                    anchors.centerIn: parent
                    pointSize: Styles.textMd
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
            backgroundColor: root.player?.isPlaying ? Colors.error : Qt.lighter(Colors.surface, Colors.lighter)
            iconColor: root.player?.isPlaying ? Colors.surface : Colors.onSurface
            iconText: "󰐎"
            onClicked: root.player.togglePlaying()
        }
        ButtonStyledLocal {
            iconText: "󰒭"
            onClicked: root.player.next()
        }
    }
}
