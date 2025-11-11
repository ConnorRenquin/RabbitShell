import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Hyprland

import qs.Constants

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore

    anchors.right: true
    margins.right: 20

    width: 650
    height: rect.implicitHeight
    color: "transparent"
    visible: false

    GlobalShortcut {
        name: "mixer"
        onPressed: {
            console.log("Mixer shortcut pressed");
            root.visible = !root.visible;
        }
    }

    Rectangle {
        id: rect
        implicitWidth: width
        implicitHeight: column.implicitHeight + 20
        width: parent.width
        height: parent.height
        color: Colors.bgDim
        radius: 10

        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10

            // get a list of nodes that output to the default sink
            PwNodeLinkTracker {
                id: linkTracker
                node: Pipewire.defaultAudioSink
            }

            MixerEntry {
                node: Pipewire.defaultAudioSink
                Layout.fillWidth: true
            }

            Repeater {
                model: linkTracker.linkGroups

                MixerEntry {
                    required property PwLinkGroup modelData
                    // Each link group contains a source and a target.
                    // Since the target is the default sink, we want the source.
                    node: modelData.source
                    Layout.fillWidth: true
                }
            }
        }
    }
}
