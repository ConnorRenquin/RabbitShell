import Quickshell.Services.Mpris

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    color: Colors.backgroundLifted
    ScrollView {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        contentWidth: availableWidth
        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Styles.marginSm
            spacing: Styles.marginMd
            TextStyled {
                text: "Audio Settings"
                font.pixelSize: Styles.textLg
            }
            Repeater {
                model: [Audio.sink, ...Audio.links]
                delegate: PipewireControls {
                    Layout.fillWidth: true
                }
            }
            Repeater {
                model: Mpris.players
                delegate: MprisControls {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
