import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Services

ColumnLayout {
    id: root
    required property PwNode modelData
    property bool isCurrentItem: false

    spacing: Styles.marginSm

    function decrease() {
        slider.decrease();
    }

    function increase() {
        slider.increase();
    }

    function toggleMute() {
        root.modelData.audio.muted = !root.modelData.audio.muted;
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Styles.marginSm

        TextStyled {
            text: "󰓃"
            font.pixelSize: Styles.textLg
        }

        Rectangle {
            color: root.isCurrentItem ? Colors.backgroundLifted : Colors.background
            radius: Styles.radiusLg
            Layout.fillWidth: true
            Layout.fillHeight: true
            TextStyled {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                verticalAlignment: Text.AlignVCenter
                text: Audio.getName(root.modelData)
            }
        }

        ButtonStyled {
            text: root.modelData.audio?.muted ? "" : ""
            onClicked: root.modelData.audio.muted = !root.modelData.audio.muted
        }
    }

    SliderStyled {
        id: slider
        Layout.fillWidth: true
        onValueChanged: root.modelData.audio.volume = value
        Component.onCompleted: value = root.modelData.audio.volume
    }
}
