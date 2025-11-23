import Quickshell
import Quickshell.Widgets
import QtQuick
import Quickshell.Services.SystemTray

import qs.Components
import qs.Constants

BarWidget {
    id: root
    property int iconSize: 20

    implicitWidth: row.implicitWidth + Styles.marginSm * 2
    Row {
        id: row
        anchors.centerIn: parent
        spacing: Styles.marginSm

        Repeater {
            id: trayRow
            model: SystemTray.items

            delegate: ButtonStyled {
                id: menuItem

                defaultColor: Colors.bg0
                hoverColor: Colors.bg1

                implicitWidth: root.iconSize + Styles.marginSm
                implicitHeight: root.iconSize + Styles.marginSm
                radius: Styles.radiusSm

                onClicked: trayMenu.toggleVisible()

                IconImage {
                    id: icon
                    anchors.centerIn: parent
                    width: root.iconSize
                    height: root.iconSize
                    source: modelData.icon

                    SystemTrayMenu {
                        id: trayMenu
                        trayMenu: modelData.menu
                    }
                }
            }
        }
    }
}
