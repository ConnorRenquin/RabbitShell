pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Quickshell.Hyprland

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Loader {
    id: loader

    active: false

    GlobalShortcut {
        name: "mixer"
        onPressed: active = !active
    }

    sourceComponent: PanelWindow {
        id: root

        exclusionMode: ExclusionMode.Ignore

        anchors.top: true
        margins.top: 60

        implicitWidth: 650
        implicitHeight: Math.min(300, mixerList.implicitHeight + Styles.marginSm * 2)
        color: "transparent"

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        Rectangle {
            id: base
            focus: true
            anchors.fill: parent
            color: Colors.background
            radius: Styles.radiusSm

            Keys.onPressed: event => {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    loader.active = false;
                } else if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                    mixerList.incrementCurrentIndex();
                } else if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                    mixerList.decrementCurrentIndex();
                } else if ([Qt.Key_Left, Qt.Key_H].includes(event.key)) {
                    if (mixerList.currentItem && mixerList.currentItem.modelData) {
                        mixerList.currentItem.decrease();
                    }
                } else if ([Qt.Key_Right, Qt.Key_L].includes(event.key)) {
                    if (mixerList.currentItem && mixerList.currentItem.modelData) {
                        mixerList.currentItem.increase();
                    }
                } else if ([Qt.Key_M].includes(event.key)) {
                    if (mixerList.currentItem && mixerList.currentItem.modelData) {
                        mixerList.currentItem.toggleMute();
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                contentWidth: availableWidth
                ColumnLayoutPlus {
                    id: mixerList
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm
                    Repeater {
                        model: [Audio.sink]
                        delegate: PipewireControls {
                            Layout.fillWidth: true
                            isCurrentItem: mixerList.currentItem === this
                        }
                    }
                    Repeater {
                        model: Mpris.players
                        delegate: MprisControls {
                            Layout.fillWidth: true
                            isCurrentItem: mixerList.currentItem === this
                        }
                    }
                }
            }
        }
    }
}
