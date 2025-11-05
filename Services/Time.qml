pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm:ss AP")
    readonly property string date: Qt.formatDateTime(clock.date, "MM-dd-yyyy")
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
