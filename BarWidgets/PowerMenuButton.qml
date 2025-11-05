import QtQuick
import qs.Constants

Rectangle {
    id: menuButton

    property string label: ""
    property string command: ""
    signal clicked

    height: 40
    width: parent.width
    color: mouseArea.containsMouse ? Colors.bg0 : "transparent"
    radius: 3

    Text {
        anchors.centerIn: parent
        text: menuButton.label
        color: Colors.yellow
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            menuButton.clicked();
        }
    }
}
