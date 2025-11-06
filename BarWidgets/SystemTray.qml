import Quickshell
import Quickshell.Widgets
import QtQuick
import Quickshell.Services.SystemTray
import qs.Constants

BarWidget {
    id: root
    width: row.implicitWidth + 20  // Dynamic width based on content
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
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.bg2
                height: Constants.widgetHeight - 10
                width: icon.implicitWidth + 30
                radius: 5
                IconImage {
                    id: icon
                    anchors.centerIn: parent
                    source: modelData.icon
                    width: 23
                    height: 23
                    SystemTrayMenu {
                        parentItem: menuItem
                        visible: menuItem.menuVisible
                        trayMenu: modelData.menu
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        menuItem.menuVisible = !menuItem.menuVisible;
                    }
                }
            }
        }
    }
}
