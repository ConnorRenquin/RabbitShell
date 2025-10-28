import Quickshell
import Quickshell.Widgets
import QtQuick
import Quickshell.Services.SystemTray

Rectangle {
    height: Constants.widgetHeight
    width: row.implicitWidth + 20  // Dynamic width based on content
    color: Colors.bgDim
    radius: 5

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: SystemTray.items

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.bg2
                height: Constants.widgetHeight - 10
                width: icon.implicitWidth + 30  // Dynamic width based on icon
                radius: 5

                IconImage {
                    id: icon
                    anchors.centerIn: parent
                    source: modelData.icon
                    width: 20  // Set desired icon size
                    height: 20
                }
            }
        }
    }
}
