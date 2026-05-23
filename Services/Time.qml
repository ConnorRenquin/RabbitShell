pragma Singleton

import Quickshell

import QtQuick

import qs.Settings

Singleton {
    readonly property string time: Qt.formatDateTime(clock.date, "HH:mm:ss")
    readonly property string timeShort: Qt.formatDateTime(clock.date, "hh:mm AP")
    readonly property string date: Qt.formatDateTime(clock.date, "MM-dd-yyyy")
    readonly property int hour: parseInt(Qt.formatDateTime(clock.date, "h"))

    property bool militaryTime: false

    Component.onCompleted: {
        militaryTime = Settings.register({ name: 'militaryTime', value: false, category: 'appearance' }).value;
    }

    Connections {
        target: Settings
        function onSettingsChanged() {
            const s = Settings.settings.find(x => x.name === 'militaryTime');
            if (s) militaryTime = s.value;
        }
    }

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

    function getSymbolAtIndex(symbolIndex) {
        return clockSymbols[symbolIndex]
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
