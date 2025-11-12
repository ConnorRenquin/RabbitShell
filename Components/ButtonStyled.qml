import Quickshell
import QtQuick

import qs.Constants

Rectangle {
    id: root
    color: mouseArea.containsMouse ? Colors.bg2 : Colors.bgDim
    scale: mouseArea.pressed ? 0.95 : 1

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
            duration: 100
            easing.type: Easing.OutQuad
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
