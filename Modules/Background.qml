import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick

import qs.Settings
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
                source: root.player !== null ? root.player.trackArtUrl : ''
            }

            DoubleText {
                pointSize: 34
                offset: 4
                width: albumArt.width - Styles.marginSm * 2
                anchors.bottom: parent.bottom
                anchors.margins: root.clockMargin + Styles.marginSm
                anchors.horizontalCenter: parent.horizontalCenter
                text: Icons.nowPlaying + ' ' + root.player?.trackTitle + ' - ' + root.player?.trackArtist
            }
        }

        DoubleText {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            pointSize: 120
            text: Time.getTime()
        }
    }
}
