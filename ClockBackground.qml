import Quickshell
import Quickshell.Widgets
import QtQuick

import qs.Constants
import qs.Components
import qs.Services

PanelWindow {

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight

    exclusionMode: ExclusionMode.Normal
    color: Colors.transparent
    aboveWindows: false

    TextStyled {
        id: clockText
        antialiasing: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        font.pixelSize: 142
        color: Colors.bgVisual
        text: Time.timeShort
    }

    TextStyled {
        antialiasing: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        font.pixelSize: 140
        color: Colors.fg
        text: Time.timeShort
    }
}
