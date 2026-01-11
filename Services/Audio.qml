pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQml

Singleton {
    id: root

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

    property var nodeStates: ({})
    readonly property list<PwNode> links: linkGroups.sources
    readonly property list<PwNode> sinks: nodes.sinks
    readonly property list<PwNode> sources: nodes.sources

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    function setAudioSink(newSink: PwNode): void {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource: PwNode): void {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    function getNodeState(node) {
        return nodeStates[node?.id] ?? null;
    }

    PwNodeLinkTracker {
        id: linkTracker
        node: Pipewire?.defaultAudioSink
    }

    PwObjectTracker {
        objects: [...root.sinks, ...root.sources, ...root.links]
    }

    Instantiator {
        model: [root.sink, ...root.links]
        delegate: AudioNodeState {
            required property var modelData
            node: modelData
            Component.onCompleted: root.nodeStates[modelData.id] = this
            Component.onDestruction: delete root.nodeStates[modelData.id]
        }
    }
}
