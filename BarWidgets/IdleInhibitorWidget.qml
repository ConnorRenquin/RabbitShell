import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Components
import qs.Constants

BarWidget {
    id: root
    width: parent.height
    color: inhibitIdle ? Colors.orange : Colors.bgDim

    property bool inhibitIdle: false

    TextStyled {
        id: textIcon
        anchors.centerIn: parent
        text: inhibitIdle ? "󰅶" : "󰛊"
        color: Colors.fg
    }

    IdleInhibitor {
        enabled: inhibitIdle
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            mask: Region {}
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggle();
            clickAnimation.start();
        }
    }

    function toggle() {
        inhibitIdle = !inhibitIdle;
    }
}
