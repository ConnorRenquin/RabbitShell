import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Settings.SettingsViews.Components
import qs.Services

Rectangle {
    id: root
    color: theme.background

    Themer { id: theme; variant: 'secondary' }

    Utils {
        id: utils
    }

    Component.onCompleted: {
        System.loadSystemInfo();
    }

    ColumnLayoutPlus {
        anchors.fill: parent
        anchors.margins: Styles.marginSm

        SettingsViewTitle {
            title: "About"
        }

        ColumnLayout {
            id: infoGrid

            component InformationGroup: ColumnLayout {
                id: informationGroup
                property string title
                property string info
                Layout.fillWidth: true
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

        Item {
            Layout.fillHeight: true
        }

        ColorPalette {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
        }
    }
}
