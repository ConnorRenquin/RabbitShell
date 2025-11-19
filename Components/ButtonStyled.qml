import Quickshell
import QtQuick

import qs.Constants

Rectangle {
    id: root

    property string hoverColor: Colors.bg2
    property string defaultColor: Colors.bgDim
    property string focusedColor: Colors.orange

    color: {
        if (mouseArea.containsMouse)
            return hoverColor;
        if (isFocused)
            return focusedColor;
        else
            return defaultColor;
    }
    scale: mouseArea.pressed ? 0.90 : 1

    property bool isFocused: false
    property bool containsMouse: mouseArea.containsMouse
    default property alias content: contentItem.data
    signal clicked(var mouse)

    Behavior on color {
        ColorAnimation {
            duration: 250
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 50
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: mouse => root.clicked(mouse)
    }
}
