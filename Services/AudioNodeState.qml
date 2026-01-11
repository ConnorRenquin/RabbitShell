import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    required property PwNode node

    Component.onCompleted: {
        if (node?.audio) {
            volume = node.audio.volume;
            muted = node.audio.muted;
        }
    }

    property real volume: 0
    property bool muted: node?.audio?.muted ?? false
    property bool updating: false

    function getName() {
        return node?.description !== '' ? node?.description : node.name;
    }

    function setVolume(newVolume) {
        if (!node?.audio)
            return;
        root.updating = true;
        root.volume = newVolume;
        node.audio.volume = newVolume;
        root.updating = false;
    }

    function setMuted(newMuted) {
        if (!node?.audio)
            return;
        root.updating = true;
        root.muted = newMuted;
        node.audio.muted = newMuted;
        root.updating = false;
    }

    Connections {
        target: root.node?.audio
        enabled: !!node?.audio

        // Reset the volume to root.
        function onVolumeChanged() {
            if (!root.updating) {
                root.updating = true;
                root.node.audio.volume = root.volume;
                root.updating = false;
            }
        }

        function onMutedChanged() {
            if (!root.updating) {
                root.muted = root.node.audio.muted;
            }
        }
    }
}
