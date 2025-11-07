import Quickshell
import QtQuick

import qs.Components
import qs.Constants

BarWidget {
    id: root

    property string icon: "*"
    property string command

    width: parent.height

    color: mouseArea.containsMouse ? Colors.bgGreen : Colors.bgDim

    Behavior on color {
        ColorAnimation {
            duration: 125
        }
    }

    // TODO Switch over to svg at some point?
    TextStyled {
        id: text
        text: icon
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            Quickshell.execDetached(["bash", "-c", root.command]);
        }
    }
}
