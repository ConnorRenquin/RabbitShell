pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components
import qs.Services

import "../Components"

FloatingWindowPlus {
    id: root

    title: 'Time Manager'
    shortcutName: "timemanager"

    property int currentTab: 0 // 0: Timers, 1: Stopwatch, 2: Alarms

    // Timers State
    property var activeTimers: []

    // Stopwatch State
    property var laps: []

    // Alarms State
    property var alarms: []

    // Dynamic Timer Component
    Component {
        id: timerPlusComponent
        TimerPlus {}
    }

    // Dynamic Timer Management
    function addTimer(hours, minutes, seconds) {
        console.log("addTimer called with:", hours, "hours,", minutes, "minutes,", seconds, "seconds");
        let totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
        console.log("totalSeconds calculated:", totalSeconds);
        if (totalSeconds <= 0) {
            console.log("totalSeconds is <= 0, returning");
            return;
        }

        let timerInstance = timerPlusComponent.createObject(root, {
            duration: totalSeconds,
            running: true
        });
        console.log("timerInstance created:", timerInstance);

        if (timerInstance) {
            timerInstance.triggered.connect(() => {
                console.log("Timer triggered!");
                Quickshell.execDetached(['notify-send', '-a', 'Timer', 'Timer Finished!']);
                SoundEffects.playUrgent();
                removeTimerInstance(timerInstance);
            });

            timerInstance.start();
            console.log("timerInstance started, remaining:", timerInstance.remaining);

            activeTimers.push(timerInstance);
            activeTimers = [...activeTimers];

            timersModel.append({ "duration": totalSeconds });
            console.log("Added timer to model, timersModel count:", timersModel.count);
            saveTimers();
        } else {
            console.log("Failed to create timerInstance!");
        }
    }

    function removeTimerInstance(instance) {
        let index = activeTimers.indexOf(instance);
        if (index !== -1) {
            instance.destroy();
            activeTimers.splice(index, 1);
            activeTimers = [...activeTimers];
            timersModel.remove(index);
            saveTimers();
        }
    }

    function saveTimers() {
        let timersData = [];
        for (let i = 0; i < root.activeTimers.length; i++) {
            let t = root.activeTimers[i];
            timersData.push({
                duration: t.duration,
                remaining: t.remaining,
                paused: t.paused,
                running: t.running,
                savedAt: Date.now()
            });
        }
        persistentTimers.save({
            timers: timersData
        });
    }

    // Periodic save for running timers
    Timer {
        interval: 5000 // 5 seconds
        running: root.activeTimers.length > 0
        repeat: true
        onTriggered: saveTimers()
    }

    FileViewPlus {
        id: persistentTimers
        path: Qt.resolvedUrl('../Settings/.data/timers.json')
        defaultValue: ({ "timers": [] })

        onDataLoaded: parsed => {
            if (parsed.timers && parsed.timers.length > 0) {
                let now = Date.now();
                for (let i = 0; i < parsed.timers.length; i++) {
                    let savedTimer = parsed.timers[i];
                    let remaining = savedTimer.remaining;

                    if (savedTimer.running && !savedTimer.paused) {
                        let elapsedMs = now - savedTimer.savedAt;
                        let elapsedSecs = Math.floor(elapsedMs / 1000);
                        remaining -= elapsedSecs;
                    }

                    if (remaining > 0) {
                        let timerInstance = timerPlusComponent.createObject(root, {
                            duration: savedTimer.duration,
                            remaining: remaining,
                            running: savedTimer.running,
                            paused: savedTimer.paused
                        });

                        if (timerInstance) {
                            timerInstance.triggered.connect(() => {
                                Quickshell.execDetached(['notify-send', '-a', 'Timer', 'Timer Finished!']);
                                SoundEffects.playUrgent();
                                removeTimerInstance(timerInstance);
                            });

                                if (savedTimer.running && !savedTimer.paused) {
                                    timerInstance.internalTimer.start();
                                }

                                root.activeTimers.push(timerInstance);
                                timersModel.append({ "duration": savedTimer.duration });
                            }
                        }
                    }
                    root.activeTimers = [...root.activeTimers];
                }
            }
        }

    FileViewPlus {
        id: persistentAlarms
        path: Qt.resolvedUrl('../Settings/.data/alarms.json')
        defaultValue: ({ "alarms": [] })

        onDataLoaded: parsed => {
            if (parsed.alarms) {
                root.alarms = parsed.alarms;
            }
        }
    }

    // Alarm Management
    function addAlarm(name, hour, minute, ampm) {
        let formattedTime = `${hour}:${minute < 10 ? '0' + minute : minute} ${ampm}`;
        alarms.push({
            name: name || "Alarm",
            time: formattedTime,
            enabled: true
        });
        alarms = [...alarms];
        saveAlarms();
    }

    function removeAlarm(index) {
        alarms.splice(index, 1);
        alarms = [...alarms];
        saveAlarms();
    }

    function toggleAlarm(index) {
        alarms[index].enabled = !alarms[index].enabled;
        alarms = [...alarms];
        saveAlarms();
    }

    function saveAlarms() {
        persistentAlarms.save({
            alarms: root.alarms
        });
    }

    // Alarm Checker
    Timer {
        interval: 60000 // Check every minute
        running: true
        repeat: true
        onTriggered: {
            let now = new Date();
            let currentHour = now.getHours();
            let currentMinute = now.getMinutes();

            for (let i = 0; i < root.alarms.length; i++) {
                let alarm = root.alarms[i];
                if (alarm.enabled) {
                    let parts = alarm.time.split(" ");
                    let timeParts = parts[0].split(":");
                    let alarmHour = parseInt(timeParts[0]);
                    let alarmMinute = parseInt(timeParts[1]);
                    let ampm = parts[1];

                    if (ampm === "PM" && alarmHour < 12) alarmHour += 12;
                    if (ampm === "AM" && alarmHour === 12) alarmHour = 0;

                    if (currentHour === alarmHour && currentMinute === alarmMinute) {
                        Quickshell.execDetached(['notify-send', '-a', 'Alarm', 'Alarm Triggered!', alarm.name]);
                        SoundEffects.playWakeUp();
                    }
                }
            }
        }
    }

    // Stopwatch Instance
    TimerPlus {
        id: stopwatch
        duration: 0 // Count up
        repeat: true
    }

    // ListModel for Timers UI Reactivity
    ListModel {
        id: timersModel
    }

    delegate: Rectangle {
        id: base
        anchors.fill: parent
        color: Colors.background
        radius: Styles.radiusSm
        focus: true

        ColumnLayout {
            anchors.fill: parent
            Rectangle {
                id: tabBar
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Colors.surface
                radius: Styles.radiusSm

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm

                    TextStyled {
                        font.pointSize: Styles.textLg
                        text: {
                            if (root.currentTab === 0) {
                                return "Timers"
                            } else if (root.currentTab === 1) {
                                return "Stopwatch"
                            }  else if (root.currentTab === 2) {
                                return "Alarms"
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ButtonStyled {
                        Layout.fillHeight: true
                        text: Icons.hourGlass
                        isFocused: root.currentTab === 0
                        defaultColor: root.currentTab === 0 ? Colors.primary : Colors.surfaceVariant
                        textColor: root.currentTab === 0 ? Colors.onPrimary : Colors.onSurface
                        onClicked: root.currentTab = 0
                    }

                    ButtonStyled {
                        Layout.fillHeight: true
                        text: Icons.clock
                        isFocused: root.currentTab === 1
                        defaultColor: root.currentTab === 1 ? Colors.primary : Colors.surfaceVariant
                        textColor: root.currentTab === 1 ? Colors.onPrimary : Colors.onSurface
                        onClicked: root.currentTab = 1
                    }

                    ButtonStyled {
                        Layout.fillHeight: true
                        text: Icons.alarm
                        isFocused: root.currentTab === 2
                        defaultColor: root.currentTab === 2 ? Colors.primary : Colors.surfaceVariant
                        textColor: root.currentTab === 2 ? Colors.onPrimary : Colors.onSurface
                        onClicked: root.currentTab = 2
                    }
                }
            }

            // Body Area
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.currentTab

                // 1. Timers Tab
                Rectangle {
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginMd
                        spacing: Styles.marginSm

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: Styles.marginSm

                                Repeater {
                                    model: timersModel

                                    delegate: Rectangle {
                                        id: timerRow
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50
                                        color: Colors.surface
                                        radius: Styles.radiusSm

                                        readonly property var timerInstance: root.activeTimers[index]

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: Styles.marginSm

                                            TextStyled {
                                                text: "Timer " + (timerRow.index + 1)
                                                Layout.fillWidth: true
                                                font.bold: true
                                            }

                                            TextStyled {
                                                text: timerRow.timerInstance ? timerRow.timerInstance.formattedRemaining : "00:00"
                                                font.family: Styles.defaultFontFamily
                                                font.bold: true
                                                color: Colors.primary
                                            }

                                            ButtonStyled {
                                                implicitWidth: 60
                                                implicitHeight: 30
                                                text: timerRow.timerInstance && timerRow.timerInstance.paused ? "Resume" : "Pause"
                                                defaultColor: Colors.surfaceVariant
                                                onClicked: {
                                                    if (timerRow.timerInstance) {
                                                        if (timerRow.timerInstance.paused) {
                                                            timerRow.timerInstance.resume();
                                                        } else {
                                                            timerRow.timerInstance.pause();
                                                        }
                                                        root.saveTimers();
                                                    }
                                                }
                                            }

                                            ButtonStyled {
                                                implicitWidth: 60
                                                implicitHeight: 30
                                                text: "Delete"
                                                defaultColor: Colors.error
                                                textColor: Colors.onError
                                                onClicked: {
                                                    if (timerRow.timerInstance) {
                                                        root.removeTimerInstance(timerRow.timerInstance);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Add Timer Inputs
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: Colors.surface
                            radius: Styles.radiusSm

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Styles.marginSm
                                spacing: Styles.marginSm

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    TextStyled { text: "Hrs"; font.pointSize: Styles.textSm; color: Colors.outline }
                                    TextFieldStyled {
                                        id: timerHrsInput
                                        Layout.fillWidth: true
                                        placeholderText: "0"
                                        inputMethodHints: Qt.ImhDigitsOnly
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    TextStyled { text: "Mins"; font.pointSize: Styles.textSm; color: Colors.outline }
                                    TextFieldStyled {
                                        id: timerMinsInput
                                        Layout.fillWidth: true
                                        placeholderText: "5"
                                        inputMethodHints: Qt.ImhDigitsOnly
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    TextStyled { text: "Secs"; font.pointSize: Styles.textSm; color: Colors.outline }
                                    TextFieldStyled {
                                        id: timerSecsInput
                                        Layout.fillWidth: true
                                        placeholderText: "0"
                                        inputMethodHints: Qt.ImhDigitsOnly
                                    }
                                }

                                ButtonStyled {
                                    Layout.preferredHeight: 40
                                    text: "Add Timer"
                                    defaultColor: Colors.primary
                                    textColor: Colors.onPrimary
                                    onClicked: {
                                        let hrsText = timerHrsInput.text.trim();
                                        let minsText = timerMinsInput.text.trim();
                                        let secsText = timerSecsInput.text.trim();

                                        // If all are empty, default to 5 minutes (matching the placeholder)
                                        if (hrsText === "" && minsText === "" && secsText === "") {
                                            minsText = "5";
                                        }

                                        let hrs = parseInt(hrsText);
                                        let mins = parseInt(minsText);
                                        let secs = parseInt(secsText);
                                        if (isNaN(hrs)) hrs = 0;
                                        if (isNaN(mins)) mins = 0;
                                        if (isNaN(secs)) secs = 0;

                                        root.addTimer(hrs, mins, secs);
                                        timerHrsInput.text = "";
                                        timerMinsInput.text = "";
                                        timerSecsInput.text = "";
                                    }
                                }
                            }
                        }
                    }
                }

                // 2. Stopwatch Tab
                Rectangle {
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginMd
                        spacing: Styles.marginMd

                        // Big Time Display
                        TextStyled {
                            text: stopwatch.formattedElapsed
                            font.pointSize: 48
                            font.bold: true
                            font.family: Styles.defaultFontFamily
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            color: Colors.primary
                        }

                        // Controls
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Styles.marginMd

                            ButtonStyled {
                                implicitWidth: 100
                                implicitHeight: 40
                                text: stopwatch.running ? (stopwatch.paused ? "Resume" : "Pause") : "Start"
                                defaultColor: stopwatch.running && !stopwatch.paused ? Colors.error : Colors.primary
                                textColor: stopwatch.running && !stopwatch.paused ? Colors.onError : Colors.onPrimary
                                onClicked: {
                                    if (!stopwatch.running) {
                                        stopwatch.start();
                                    } else if (stopwatch.paused) {
                                        stopwatch.resume();
                                    } else {
                                        stopwatch.pause();
                                    }
                                }
                            }

                            ButtonStyled {
                                implicitWidth: 100
                                implicitHeight: 40
                                text: "Lap"
                                defaultColor: Colors.surfaceVariant
                                textColor: Colors.onSurface
                                enabled: stopwatch.running
                                onClicked: {
                                    root.laps.push(stopwatch.formattedElapsed);
                                    root.laps = [...root.laps];
                                }
                            }

                            ButtonStyled {
                                implicitWidth: 100
                                implicitHeight: 40
                                text: "Reset"
                                defaultColor: Colors.surfaceVariant
                                textColor: Colors.onSurface
                                onClicked: {
                                    stopwatch.reset();
                                    root.laps = [];
                                }
                            }
                        }

                        ScrollView {
                            id: lapsList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: Styles.marginSm

                                Repeater {
                                    model: root.laps
                                    delegate: Rectangle {
                                        id: lapRow
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 35
                                        color: Colors.surface
                                        radius: Styles.radiusSm

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: Styles.marginMd
                                            anchors.rightMargin: Styles.marginMd

                                            TextStyled {
                                                text: "Lap " + (lapRow.index + 1)
                                                Layout.fillWidth: true
                                                color: Colors.outline
                                            }

                                            TextStyled {
                                                text: lapRow.modelData
                                                font.family: Styles.defaultFontFamily
                                                font.bold: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: alarmsTab
                    color: "transparent"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginMd
                        spacing: Styles.marginSm

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: Styles.marginSm

                                Repeater {
                                    model: root.alarms

                                    delegate: Rectangle {
                                        id: alarmRow
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 65
                                        color: Colors.surface
                                        radius: Styles.radiusSm

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: Styles.marginSm

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                TextStyled {
                                                    text: alarmRow.modelData.time
                                                    font.bold: true
                                                    font.pointSize: Styles.textLg
                                                    color: alarmRow.modelData.enabled ? Colors.primary : Colors.outline
                                                }
                                                TextStyled {
                                                    text: alarmRow.modelData.name
                                                    font.pointSize: Styles.textSm
                                                    color: Colors.outline
                                                }
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            SwitchStyled {
                                                checked: alarmRow.modelData.enabled
                                                onToggled: {
                                                    root.toggleAlarm(alarmRow.index);
                                                }
                                            }

                                            ButtonStyled {
                                                implicitHeight: 30
                                                text: "Delete"
                                                defaultColor: Colors.error
                                                textColor: Colors.onError
                                                onClicked: {
                                                    root.removeAlarm(alarmRow.index);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Add Alarm Inputs
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: Colors.surface
                            radius: Styles.radiusSm

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Styles.marginSm
                                spacing: Styles.marginSm

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    TextStyled { text: "Name"; font.pointSize: Styles.textSm; color: Colors.outline }
                                    TextFieldStyled {
                                        id: alarmNameInput
                                        Layout.fillWidth: true
                                        placeholderText: "Wake Up"
                                    }
                                }

                                ColumnLayout {
                                    Layout.preferredWidth: 50
                                    TextStyled { text: "Hour"; font.pointSize: Styles.textSm; color: Colors.outline }
                                    TextFieldStyled {
                                        id: alarmHourInput
                                        Layout.fillWidth: true
                                        placeholderText: "7"
                                        inputMethodHints: Qt.ImhDigitsOnly
                                    }
                                }

                                ColumnLayout {
                                    Layout.preferredWidth: 50
                                    TextStyled { text: "Min"; font.pointSize: Styles.textSm; color: Colors.outline }
                                    TextFieldStyled {
                                        id: alarmMinInput
                                        Layout.fillWidth: true
                                        placeholderText: "30"
                                        inputMethodHints: Qt.ImhDigitsOnly
                                    }
                                }

                                ColumnLayout {
                                    Layout.preferredWidth: 60
                                    TextStyled { text: "AM/PM"; font.pointSize: Styles.textSm; color: Colors.outline }
                                    ComboBoxStyled {
                                        id: alarmAmpmInput
                                        Layout.fillWidth: true
                                        model: ["AM", "PM"]
                                    }
                                }

                                ButtonStyled {
                                    Layout.preferredHeight: 40
                                    text: "Add"
                                    defaultColor: Colors.primary
                                    textColor: Colors.onPrimary
                                    onClicked: {
                                        let hr = parseInt(alarmHourInput.text) || 7;
                                        let min = parseInt(alarmMinInput.text) || 0;
                                        let ampm = alarmAmpmInput.model[alarmAmpmInput.currentIndex];
                                        root.addAlarm(alarmNameInput.text, hr, min, ampm);
                                        alarmNameInput.text = "";
                                        alarmHourInput.text = "";
                                        alarmMinInput.text = "";
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
