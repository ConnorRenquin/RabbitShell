import Quickshell.Services.Pipewire

import QtQuick

SliderStyled {
    id: root

    required property PwNode node

    onValueChanged: node.audio.volume = value
    Component.onCompleted: value = node.audio.volume

    Connections {
        target: root.node.audio
        function onVolumeChanged() {
            root.value = root.node.audio.volume;
        }
    }
}
