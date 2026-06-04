import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Components
import qs.Components.Styled
import qs.Settings
import qs.Modules.SettingsMenu.SettingsViews.Components
import qs.Services

Rectangle {
    id: root

    required property string name

    color: Qt.lighter(Colors.surface, Colors.lighter)
    ScrollView {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        contentWidth: availableWidth
        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Styles.marginMd

            SettingsViewTitle {
                title: root.name
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styles.marginSm

                TextStyled {
                    text: "Default Audio Sink (Output)"
                    font.pointSize: Styles.textMd
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
                    font.pointSize: Styles.textMd
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
                font.pointSize: Styles.textLg
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
