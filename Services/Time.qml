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
        name: '24 Hour Clock',
        value: false
    }).value

    function getTime() {
        if (militaryTime)
            return time;
        return timeShort;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
