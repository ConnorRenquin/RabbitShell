import Quickshell
import Quickshell.Widgets
import QtQuick
import Quickshell.Services.SystemTray
import qs.Constants

BarWidget {
    id: root

    property int iconSize: 20
    property int itemPadding: 6
    property int baseMargin: 15

    implicitWidth: row.implicitWidth + baseMargin

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            id: trayRow
            model: SystemTray.items

            Rectangle {
                id: menuItem
                property bool menuVisible: false

                width: root.iconSize + (root.itemPadding * 2)
                height: root.iconSize + (root.itemPadding * 2)

                color: mouseArea.containsMouse ? Colors.bg1 : Colors.bg0
                radius: 5

                Behavior on color {
                    ColorAnimation {
                        duration: 250
                    }
                }

                IconImage {
                    id: icon
                    anchors.centerIn: parent
                    width: root.iconSize
                    height: root.iconSize
                    source: modelData.icon

                    SystemTrayMenu {
                        parentItem: menuItem
                        visible: menuItem.menuVisible
                        trayMenu: modelData.menu
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: event => {
                        menuItem.menuVisible = !menuItem.menuVisible;
                    }
                }
            }
        }
    }
}
