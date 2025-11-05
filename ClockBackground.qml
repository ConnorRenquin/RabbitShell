import Quickshell
import QtQuick

import qs.Constants
import qs.Global
import qs.Services

PanelWindow {
    id: root

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
        anchors.centerIn: parent
        font.pixelSize: 200
        text: Time.timeShort
    }
}
