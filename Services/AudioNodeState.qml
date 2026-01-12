import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    // This whole thing is just so that spotify doesn't reset the damned volume every song...
    property bool locked: ["spotify"].includes(node.name)
    required property PwNode node

    Component.onCompleted: {
        console.log('hi');
        if (node?.audio) {
            console.log('bye');
            node.audio.volume = 0.75;
            volume = node.audio.volume;
            console.log(node.audio.volume);
            muted = node.audio.muted;
        }
    }

    property real volume: 0.75
    property bool muted: node?.audio?.muted ?? false
    property bool updating: false

    function getName() {
        return node?.description !== '' ? node?.description : node.name;
    }

    function getVolume() {
        return volume;
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
        enabled: !!root.node?.audio

        function onVolumeChanged() {
            if (!root.updating) {
                if (root.locked) {
                    root.setVolume(root.volume);
                } else {
                    root.volume = root.node.audio.volume;
                }
            }
        }

        function onMutedChanged() {
            if (!root.updating && !root.locked) {
                root.muted = root.node.audio.muted;
            }
        }
    }
}
