import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick

import qs.Constants
import qs.Components
import qs.Services

Variants {

    model: Quickshell.screens
    delegate: PanelWindow {
        id: root

        required property var modelData

        property int clockMargin: 20

        implicitWidth: Math.max(clockText.implicitWidth, albumArt.implicitWidth)
        implicitHeight: !albumArt.visible ? clockText.implicitHeight : albumArt.implicitHeight

        exclusionMode: ExclusionMode.Normal
        color: "transparent"
        aboveWindows: false
        screen: modelData

        ClippingRectangle {
            id: albumArt
            z: 0
            visible: Mpris.players.values[0].isPlaying
            color: Colors.bgDim
            property int size: Mpris.players.values[0].trackArtUrl ? 900 : 0
            anchors.top: parent.top
            implicitHeight: size
            implicitWidth: size
            radius: Styles.radiusMd
            Image {
                anchors.fill: parent
                source: Mpris.players.values[0].trackArtUrl
            }

            TextStyled {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: root.clockMargin + 8
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 24
                color: Colors.fg
                text: Mpris.players.values[0].trackTitle + " - " + Mpris.players.values[0].trackArtist
            }
        }

        TextStyled {
            id: clockText
            z: 1
            antialiasing: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.clockMargin + 8
            font.pixelSize: 140
            color: Colors.bgVisual
            text: Time.timeShort
        }

        TextStyled {
            z: 2
            antialiasing: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.clockMargin

            font.pixelSize: 140
            color: Colors.fg
            text: Time.timeShort
        }
    }
}
