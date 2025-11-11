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

    width: 550
    height: 600
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
        anchors.fill: parent
        color: Colors.bgDim
        radius: 10
        ScrollView {
            anchors.fill: parent
            contentWidth: availableWidth

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                // get a list of nodes that output to the default sink
                PwNodeLinkTracker {
                    id: linkTracker
                    node: Pipewire.defaultAudioSink
                }

                MixerEntry {
                    node: Pipewire.defaultAudioSink
                }

                Rectangle {
                    Layout.fillWidth: true
                    color: palette.active.text
                    implicitHeight: 1
                }

                Repeater {
                    model: linkTracker.linkGroups

                    MixerEntry {
                        required property PwLinkGroup modelData
                        // Each link group contains a source and a target.
                        // Since the target is the default sink, we want the source.
                        node: modelData.source
                    }
                }
            }
        }
    }
}
