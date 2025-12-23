import QtQuick

import qs.Constants

Rectangle {
    id: root

    color: {
        if (mouseArea.containsMouse)
            return hoverColor;
        if (isFocused)
            return focusedColor;
        else
            return defaultColor;
    }

    scale: mouseArea.pressed ? 0.90 : 1

    property string hoverColor: Colors.bg2
    property string defaultColor: Colors.bgDim
    property string focusedColor: Colors.orange
    property bool isFocused: false
    property bool containsMouse: mouseArea.containsMouse

    default property alias content: contentItem.data
    // TODO Have size effected by clicked.
    signal clicked(var mouse)

    Behavior on color {
        ColorAnimation {
            duration: 50
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
