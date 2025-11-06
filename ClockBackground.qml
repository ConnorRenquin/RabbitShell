import Quickshell
import Quickshell.Widgets
import QtQuick

import qs.Constants
import qs.Global
import qs.Services

PanelWindow {

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Normal
    color: Colors.transparent
    aboveWindows: false

    TextStyled {
        anchors.bottomMargin: parent.height / 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        font.pixelSize: parent.height / 10
        color: Colors.fg
        text: Time.timeShort
    }
}
