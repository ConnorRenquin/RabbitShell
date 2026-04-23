import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root
    color: Colors.surfaceContainer

    Utils {
        id: utils
    }

    Process {
        id: update
        running: false
        command: ["sh", "-c", "nixos-rebuild switch --impure"]
        stdout: StdioCollector {
            onStreamFinished: utils.notify({from: Icons.info + " System", summary: this.text})
        }
    }

    Process {
        id: updateConfigs
        running: false
        command: ["sh", "-c", "/etc/nixos/update-configs.sh"]
        stdout: StdioCollector {
            onStreamFinished: utils.notify({from: Icons.info + " System", summary: this.text})

        }
    }

    ColumnLayoutPlus {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        TextStyled {
            text: "Hello Computer"
            font.pixelSize: Styles.textLg
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
