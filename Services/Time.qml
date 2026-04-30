pragma Singleton

import Quickshell

import QtQuick

import qs.Settings

Singleton {
    readonly property string time: Qt.formatDateTime(clock.date, "HH:mm:ss")
    readonly property string timeShort: Qt.formatDateTime(clock.date, "hh:mm AP")
    readonly property string date: Qt.formatDateTime(clock.date, "MM-dd-yyyy")
    readonly property int hour: parseInt(Qt.formatDateTime(clock.date, "h"))

    property bool militaryTime: Settings.register({
        name: 'militaryTime',
        value: false
    }).value

    readonly property var clockSymbols: [
        "󱐿", "󱑀", "󱑁", "󱑂", "󱑃", "󱑄",
        "󱑅", "󱑆", "󱑇", "󱑈", "󱑉", "󱑊"
    ]

    function getTime() {
        if (militaryTime)
            return time;
        return timeShort;
    }

    function getSymbol() {
        const symbolIndex = (Time.hour % 12 - 1)
        if (symbolIndex > 0) return clockSymbols[symbolIndex]
        return clockSymbols[11]
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
