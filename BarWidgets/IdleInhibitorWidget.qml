import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Global
import qs.Constants

Rectangle {
    id: root
    width: textIcon.contentWidth + 20
    height: Constants.widgetHeight
    color: IdleInhibitor.enabled ? Colors.orange : Colors.bgDim
    radius: 5

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
