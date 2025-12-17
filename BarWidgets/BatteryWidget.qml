import Quickshell
import Quickshell.Services.UPower

import QtQuick

import qs.Constants
import qs.Components

BarWidget {
    id: root

    visible: UPower.onBattery

    implicitHeight: parent.implicitHeight
    implicitWidth: text.implicitWidth + Styles.marginSm * 2
    radius: Styles.radiusSm

    TextStyled {
        id: text
        anchors.centerIn: parent
        text: "󰁹 " + Math.round(UPower.displayDevice.percentage * 100) + "%"
    }
}
