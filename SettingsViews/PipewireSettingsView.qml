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
            model: Object.values(Audio.nodeStates)
            delegate: RowLayout {
                id: mixerEntry
                required property AudioNodeState modelData
                property PwNode node: modelData.node
                spacing: Styles.marginMd
                Layout.preferredHeight: 50
                TextStyled {
                    Layout.preferredWidth: 200
                    text: mixerEntry.modelData.getName()
                }
                ButtonStyled {
                    text: mixerEntry.modelData?.muted ? "" : ""
                    Layout.preferredWidth: 40
                    onClicked: mixerEntry.modelData.setMuted(!mixerEntry.modelData.muted)
                }
                SliderStyled {
                    id: volumeSlider
                    Layout.fillWidth: true
                    value: mixerEntry.modelData?.volume
                    onValueChanged: mixerEntry.modelData.setVolume(value)
                }
            }
        }
    }
}
