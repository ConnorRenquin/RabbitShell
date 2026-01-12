import Quickshell.Services.Pipewire

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
        contentWidth: availableWidth
        ColumnLayoutPlus {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Styles.marginSm
            spacing: Styles.marginSm
            model: [Audio.sink, ...Audio.links]
            delegate: RowLayout {
                id: mixerEntry
                required property PwNode modelData
                spacing: Styles.marginMd
                Layout.preferredHeight: 50
                TextStyled {
                    Layout.preferredWidth: 200
                    text: Audio.getName(mixerEntry.modelData)
                }
                ButtonStyled {
                    text: mixerEntry.modelData.audio?.muted ? "" : ""
                    Layout.preferredWidth: 40
                    onClicked: mixerEntry.modelData.audio.muted = !mixerEntry.modelData.audio.muted
                }
                VolumeSlider {
                    Layout.fillWidth: true
                    node: mixerEntry.modelData
                }
            }
        }
    }
}
