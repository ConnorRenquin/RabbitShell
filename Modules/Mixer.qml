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
import qs.Helpers

Loader {
    id: loader

    active: false

    function toggle() {
        loader.active = !loader.active;
    }

    Component.onCompleted: PatchBay.openMixer.connect(toggle)


    GlobalShortcut {
        name: "mixer"
        onPressed: loader.toggle()
    }

    sourceComponent: PanelWindow {
        id: root

        exclusionMode: ExclusionMode.Ignore

        property bool topBar: Settings.get('barPosition').value
        anchors.top: true
        margins.top: topBar ? Styles.marginMd * 3 : Styles.marginSm

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
            color: Colors.surface
            radius: Styles.radiusSm

            Controls {
                id: controls
            }

            Keys.onPressed: event => {
                if (controls.quitPressed(event)) {
                    loader.active = false;
                } else if (controls.downPressed(event)) {
                    mixerList.incrementCurrentIndex();
                    scrollView.scrollToItem();
                } else if (controls.upPressed(event)) {
                    mixerList.decrementCurrentIndex();
                    scrollView.scrollToItem();
                } else if (controls.leftPressed(event)) {
                    if (mixerList.currentItem && mixerList.currentItem.modelData) {
                        mixerList.currentItem.decrease();
                    }
                } else if (controls.rightPressed(event)) {
                    if (mixerList.currentItem && mixerList.currentItem.modelData) {
                        mixerList.currentItem.increase();
                    }
                } else if (controls.mPressed(event)) {
                    if (mixerList.currentItem && mixerList.currentItem.modelData) {
                        mixerList.currentItem.toggleMute();
                    }
                }
            }

            ScrollViewPlus {
                id: scrollView
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                contentWidth: availableWidth
                ColumnLayoutPlus {
                    id: mixerList
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Styles.marginSm
                    Repeater {
                        model: [Audio.sink, ...Audio.links.filter(node => node.name !== "spotify")]
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
