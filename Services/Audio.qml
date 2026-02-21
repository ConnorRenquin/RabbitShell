pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQml

Singleton {
    id: root

    function init() {
        console.log('Audio -----------------------------------------');
    }

    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink)
                acc.sinks.push(node);
            else if (node.audio)
                acc.sources.push(node);
        }
        return acc;
    }, {
        sources: [],
        sinks: []
    })

    readonly property var linkGroups: linkTracker.linkGroups.reduce((acc, group) => {
        acc.sources.push(group.source);
        return acc;
    }, {
        sources: []
    })

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property list<PwNode> links: linkGroups.sources
    readonly property list<PwNode> sinks: nodes.sinks
    readonly property list<PwNode> sources: nodes.sources

    function getName(node) {
        if (!node) {
            return "Audio";
        }
        return node?.description !== '' ? node?.description : node.name;
    }

    function setAudioSink(newSink: PwNode): void {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource: PwNode): void {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    PwNodeLinkTracker {
        id: linkTracker
        node: Pipewire?.defaultAudioSink
    }

    PwObjectTracker {
        objects: [root.sink, ...root.links]
    }
}
