import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    color: Colors.backgroundLighter
    ScrollView {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        contentWidth: availableWidth
        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Styles.marginSm
            spacing: Styles.marginMd

            TextStyled {
                text: "Audio Settings"
                font.pixelSize: Styles.textLg
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styles.marginSm

                TextStyled {
                    text: "Default Audio Sink (Output)"
                    font.pixelSize: Styles.textMd
                }

                ComboBoxStyled {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    model: Audio.sinks.map(node => Audio.getName(node))
                    currentIndex: {
                        const defaultSink = Pipewire.defaultAudioSink;
                        return Audio.sinks.findIndex(node => node === defaultSink);
                    }
                    onActivated: Audio.setAudioSink(Audio.sinks[currentIndex])
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styles.marginSm

                TextStyled {
                    text: "Default Audio Source (Input)"
                    font.pixelSize: Styles.textMd
                }

                ComboBoxStyled {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    model: Audio.sources.map(node => Audio.getName(node))
                    currentIndex: {
                        const defaultSource = Pipewire.defaultAudioSource;
                        return Audio.sources.findIndex(node => node === defaultSource);
                    }
                    onActivated: Audio.setAudioSource(Audio.sources[currentIndex])
                }
            }
            TextStyled {
                text: "Mixer"
                font.pixelSize: Styles.textLg
            }
            Repeater {
                model: [Audio.sink, ...Audio.links]
                delegate: PipewireControls {
                    Layout.fillWidth: true
                }
            }
            Repeater {
                model: Mpris.players
                delegate: MprisControls {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
