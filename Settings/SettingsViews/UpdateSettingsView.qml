import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root
    color: theme.containerText

    Themer { id: theme; variant: 'secondary' }

    Utils {
        id: utils
    }

    Component.onCompleted: {
        System.loadSystemInfo();
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
        command: ["sh", "-c", "/etc/nixos/scripts/update-configs.sh"]
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

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: theme.mainContainer
            radius: Styles.radiusMd

            visible: System.systemInfo !== null

            ColumnLayout {
                id: infoGrid
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Styles.marginSm
                }

                component InformationGroup: ColumnLayout {
                    id: informationGroup
                    property string title
                    property string info
                    Layout.fillWidth: tue
                    TextStyled {
                        text: informationGroup.title
                        font.pointSize: Styles.textLg
                    }
                    TextStyled {
                        text: informationGroup.info
                    }

                }

                InformationGroup {
                    title: "Host"
                    info: System.systemInfo?.hostName + " — " + (System.systemInfo?.hostModel || "")
                }

                InformationGroup {
                    title: "OS"
                    info: System.systemInfo?.os || ""
                }

                InformationGroup {
                    title: "Kernel"
                    info: System.systemInfo?.kernel || ""
                }

                InformationGroup {
                    title: "CPU"
                    info: System.systemInfo?.cpu || ""
                }

                InformationGroup {
                    title: "Packages"
                    info: System.systemInfo?.packages || ""
                }
            }
        }

        ColorPalette {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
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
