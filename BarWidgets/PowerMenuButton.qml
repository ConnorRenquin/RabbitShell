import QtQuick

import qs.Components
import qs.Constants

Rectangle {
    id: menuButton

    property string label: ""
    property string command: ""
    signal clicked

    property bool isFocused: false
    height: text.implicitHeight + 20
    implicitWidth: parent.width
    color: mouseArea.containsMouse || menuButton.isFocused ? Colors.bg1 : Colors.bg0
    radius: 10

    TextStyled {
        id: text
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
