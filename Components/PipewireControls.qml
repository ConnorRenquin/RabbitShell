import Quickshell.Services.Pipewire
import Quickshell
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Services

RowLayout {
    id: root
    required property PwNode modelData
    property bool isCurrentItem: false

    function decrease() {
        slider.decrease();
    }

    function increase() {
        slider.increase();
    }

    function toggleMute() {
        root.modelData.audio.muted = !root.modelData.audio.muted;
    }

    TextStyled {
        text: "󰓃"
        font.pixelSize: Styles.textLg
    }
    Rectangle {
        color: root.isCurrentItem ? Colors.backgroundLifted : Colors.background
        radius: Styles.radiusLg
        Layout.fillHeight: true
        Layout.preferredWidth: 150
        TextStyled {
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            text: Audio.getName(root.modelData)
        }
    }
    ButtonStyled {
        text: root.modelData.audio?.muted ? "" : ""
        Layout.preferredWidth: 40
        onClicked: root.modelData.audio.muted = !root.modelData.audio.muted
    }
    SliderStyled {
        id: slider
        Layout.fillWidth: true
        onValueChanged: root.modelData.audio.volume = value
        Component.onCompleted: value = root.modelData.audio.volume
    }
}
