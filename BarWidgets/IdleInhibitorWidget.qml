import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Components
import qs.Constants
import qs.Services

BarWidget {
    id: root
    width: parent.height
    color: IdleInhibitorSingleton.enabled ? Colors.orange : Colors.bgDim

    property bool inhibitIdle: false

    TextStyled {
        id: textIcon
        anchors.centerIn: parent
        text: IdleInhibitorSingleton.enabled ? "󰅶" : "󰛊"
        color: Colors.fg
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log("Clicked");
            IdleInhibitorSingleton.enabled = !IdleInhibitorSingleton.enabled;
        }
    }
}
