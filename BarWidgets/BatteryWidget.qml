import Quickshell
import Quickshell.Services.UPower

import QtQuick

import qs.Constants
import qs.Components

BarWidget {
    id: root
    visible: UPower.displayDevice.percentage < 0.95
    implicitWidth: text.implicitWidth + Styles.marginSm * 2

    readonly property var dischargingGlyphs: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargingGlyphs: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

    function getBatteryGlyph(percentage, charging = false) {
        var index = Math.min(9, Math.floor(percentage * 100 / 10));
        return charging ? chargingGlyphs[index] : dischargingGlyphs[index];
    }

    TextStyled {
        id: text
        anchors.centerIn: parent
        text: getBatteryGlyph(UPower.displayDevice.percentage, !UPower.onBattery) + " " + Math.round(UPower.displayDevice.percentage * 100) + "%"
    }
}
