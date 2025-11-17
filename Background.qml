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

        property MprisPlayer player: {
            var filtered = Mpris.players.values.filter(player => player.identity === "Spotify");
            return filtered.length > 0 ? filtered[0] : null;
        }

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
            visible: root.player === null || root.player.isPlaying
            color: Colors.bgDim
            anchors.top: parent.top
            radius: Styles.radiusMd

            readonly property int size: root.player !== null && root.player.isPlaying ? 900 : 0
            implicitHeight: size
            implicitWidth: size

            Image {
                anchors.fill: parent
                source: root.player !== null ? root.player.trackArtUrl : ""
            }

            TextStyled {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: root.clockMargin + Styles.marginSm
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 24
                color: Colors.fg
                text: root.player?.trackTitle + " - " + root.player?.trackArtist
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
