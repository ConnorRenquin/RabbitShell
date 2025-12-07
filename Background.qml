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

        property var modelData: null

        exclusionMode: ExclusionMode.Normal
        aboveWindows: false
        screen: modelData

        implicitWidth: 900
        implicitHeight: !albumArt?.visible ? clockText.implicitHeight : 900

        color: "transparent"

        property int clockMargin: 20
        property MprisPlayer player: {
            var filtered = Mpris.players.values.filter(player => player.identity === "Spotify");
            return filtered.length > 0 ? filtered[0] : null;
        }

        ClippingRectangle {
            id: albumArt
            visible: root.player && root.player.isPlaying
            z: 0

            radius: Styles.radiusMd
            color: "transparent"

            anchors.fill: parent
            anchors.top: parent.top

            Image {
                anchors.fill: parent
                source: root.player !== null ? root.player.trackArtUrl : ""
            }

            DoubleText {
                pixelSize: 34
                offset: 4
                text: "󰎄 " + root.player?.trackTitle + " - " + root.player?.trackArtist

                anchors {
                    bottom: parent.bottom
                    bottomMargin: root.clockMargin + Styles.marginSm
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }

        DoubleText {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            pixelSize: 160
            text: Time.timeShort
        }
    }
}
