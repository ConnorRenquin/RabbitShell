import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root
    color: Colors.onSecondary

    Utils {
        id: utils
    }

    Process {
        id: update
        running: false
        command: ["sh", "-c", "nixos-rebuild switch --impure"]
        stdout: StdioCollector {
            onStreamFinished: utils.notify({
                from: Icons.info + " System",
                summary: this.text
            })
        }
    }

    Process {
        id: updateConfigs
        running: false
        command: ["sh", "-c", "/etc/nixos/update-configs.sh"]
        stdout: StdioCollector {
            onStreamFinished: utils.notify({
                from: Icons.info + " System",
                summary: this.text
            })
        }
    }

    ColumnLayoutPlus {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        TextStyled {
            text: Settings.register({
                name: 'Welcome Message',
                value: 'Hello world!'
            }).value
            font.pointSize: Styles.textLg
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Styles.radiusLg
            color: "black"
            RowLayoutPlus {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                model: [
                    Colors.primary, Colors.onPrimary,
                    Colors.primaryContainer, Colors.onPrimaryContainer,
                    Colors.inversePrimary,
                    Colors.secondary, Colors.onSecondary,
                    Colors.secondaryContainer, Colors.onSecondaryContainer,
                    Colors.tertiary, Colors.onTertiary,
                    Colors.tertiaryContainer, Colors.onTertiaryContainer,
                    Colors.error, Colors.onError,
                    Colors.surface, Colors.onSurface,
                    Colors.surfaceVariant, Colors.onSurfaceVariant,
                    Colors.outline, Colors.outlineVariant,
                    Colors.background, Colors.onBackground,
                    Colors.shadow, Colors.scrim,
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Styles.radiusLg
                    color: modelData
                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
        RowLayout {
            Layout.fillWidth: true
            ButtonStyled {
                id: updateButton
                Layout.fillWidth: true
                text: "Update System"
                onClicked: update.running = true
            }

            ButtonStyled {
                id: updateConfigsButton
                Layout.fillWidth: true
                text: "Update Configs"
                onClicked: updateConfigs.running = true
            }
            LoadingIndicator {
                visible: update.running || updateConfigs.running
            }
        }
    }
}
