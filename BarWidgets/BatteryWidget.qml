import Quickshell.Services.UPower

import QtQuick

import qs.Settings
import qs.Components

Rectangle {
    id: root
    visible: UPower.displayDevice.percentage < 0.95 && UPower.displayDevice.isLaptopBattery
    implicitWidth: text.implicitWidth + Styles.marginSm * 2
    implicitHeight: parent.height
    radius: Styles.radiusSm
    color: Colors.background

    readonly property var dischargingGlyphs: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargingGlyphs: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

    function getBatteryGlyph(percentage, charging = false) {
        var index = Math.min(9, Math.floor(percentage * 100 / 10));
        return charging ? chargingGlyphs[index] : dischargingGlyphs[index];
    }

    TextStyled {
        id: text
        anchors.centerIn: parent
        text: root.getBatteryGlyph(UPower.displayDevice.percentage, !UPower.onBattery) + " " + Math.round(UPower.displayDevice.percentage * 100) + "%"
    }
}
