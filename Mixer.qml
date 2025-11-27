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
    margins.right: Styles.marginMd

    implicitWidth: 650
    implicitHeight: rect.implicitHeight
    color: "transparent"
    visible: false

    GlobalShortcut {
        name: "mixer"
        onPressed: root.visible = !root.visible
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
        onCleared: root.visible = false
    }

    Rectangle {
        id: rect

        focus: true

        implicitWidth: parent.width
        implicitHeight: column.implicitHeight + Styles.marginSm * 2

        color: Colors.bgDim
        radius: Styles.radiusSm

        Keys.onPressed: event => {
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
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

            if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                if (currentIndex < entries.length - 1) {
                    entries[currentIndex + 1].forceActiveFocus();
                }
            }
            if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                if (currentIndex > 0) {
                    entries[currentIndex - 1].forceActiveFocus();
                } else if (currentIndex === -1 && entries.length > 0) {
                    entries[0].forceActiveFocus();
                }
            }
        }

        onVisibleChanged: {
            if (visible)
                rect.forceActiveFocus();
        }

        ColumnLayout {
            id: column

            spacing: Styles.marginSm

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Styles.marginSm
            }

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
                delegate: MixerEntry {
                    objectName: "mixerEntry"
                    required property PwLinkGroup modelData
                    node: modelData.source
                    Layout.fillWidth: true
                }
            }
        }
    }
}
