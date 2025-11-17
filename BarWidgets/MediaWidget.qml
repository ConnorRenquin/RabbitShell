import Quickshell
import Quickshell.Services.Mpris
import QtQuick

import qs.Components
import qs.Constants

Rectangle {
    id: root
    width: row.implicitWidth + Styles.marginSm
    height: parent.height
    color: Colors.bgDim
    radius: Styles.radiusSm
    visible: root.player !== null

    property MprisPlayer player: Mpris.players.values.filter(player => player.identity === "Spotify")[0] || null

    Row {
        id: row
        anchors.left: parent.left
        anchors.margins: Styles.marginSm / 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: Styles.marginSm
        Image {
            width: root.height
            height: root.height
            source: root.player.trackArtUrl
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
            height: root.height
            defaultColor: Colors.bg0
            TextStyled {
                id: play
                anchors.centerIn: parent
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
