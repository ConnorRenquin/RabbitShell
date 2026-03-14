pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property string time: Qt.formatDateTime(clock.date, "HH:mm:ss")
    readonly property string timeShort: Qt.formatDateTime(clock.date, "hh:mm AP")
    readonly property string date: Qt.formatDateTime(clock.date, "MM-dd-yyyy")
    readonly property int hour: parseInt(Qt.formatDateTime(clock.date, "h"))
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
