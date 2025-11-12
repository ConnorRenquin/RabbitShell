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

    implicitWidth: 650
    implicitHeight: rect.implicitHeight
    color: "transparent"
    visible: false

    GlobalShortcut {
        name: "mixer"
        onPressed: {
            console.log("Mixer shortcut pressed");
            root.visible = !root.visible;
        }
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
    }

    Rectangle {
        id: rect
        implicitWidth: width
        implicitHeight: column.implicitHeight + 20
        width: parent.width
        height: parent.height
        color: Colors.bgDim
        radius: 10
        focus: true

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                root.visible = false;
                event.accepted = true;
                return;
            }

            var entries = [];
            for (var i = 0; i < column.children.length; i++) {
                var child = column.children[i];
                if (child.objectName === "mixerEntry") {
                    entries.push(child);
                }
            }

            var currentIndex = -1;
            for (var j = 0; j < entries.length; j++) {
                if (entries[j].activeFocus) {
                    currentIndex = j;
                    break;
                }
            }

            if (event.key === Qt.Key_Down) {
                if (currentIndex < entries.length - 1) {
                    entries[currentIndex + 1].forceActiveFocus();
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                if (currentIndex > 0) {
                    entries[currentIndex - 1].forceActiveFocus();
                } else if (currentIndex === -1 && entries.length > 0) {
                    entries[0].forceActiveFocus();
                }
                event.accepted = true;
            }
        }

        onVisibleChanged: {
            if (visible)
                rect.forceActiveFocus();
        }

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
                objectName: "mixerEntry"
                node: Pipewire.defaultAudioSink
                Layout.fillWidth: true
            }

            Repeater {
                model: linkTracker.linkGroups
                MixerEntry {
                    objectName: "mixerEntry"
                    required property PwLinkGroup modelData
                    node: modelData.source
                    Layout.fillWidth: true
                }
            }
        }
    }
}
