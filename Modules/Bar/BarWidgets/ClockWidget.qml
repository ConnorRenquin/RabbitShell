pragma ComponentBehavior: Bound

import QtQuick

import QtQuick.Layouts
import Quickshell

import qs.Components
import qs.Settings
import qs.Services
import qs.Helpers

Rectangle {
    id: root
    radius: Styles.radiusSm
    color: theme.background

    property var calendarMonth: {
        const now = new Date();
        return new Date(now.getFullYear(), now.getMonth(), 1);
    }
    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    function monthTitle() {
        return root.monthNames[root.calendarMonth.getMonth()] + " " + root.calendarMonth.getFullYear();
    }

    function cellDate(index) {
        const firstDay = new Date(root.calendarMonth.getFullYear(), root.calendarMonth.getMonth(), 1);
        const date = new Date(firstDay);
        date.setDate(1 - firstDay.getDay() + index);
        return date;
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    function isCurrentMonth(date) {
        return date.getFullYear() === root.calendarMonth.getFullYear() && date.getMonth() === root.calendarMonth.getMonth();
    }

    function shiftMonth(delta) {
        root.calendarMonth = new Date(root.calendarMonth.getFullYear(), root.calendarMonth.getMonth() + delta, 1);
    }

    function resetMonth() {
        const now = new Date();
        root.calendarMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    Themer {
        id: theme
        settingName: 'clockColor'
    }

    implicitWidth: contentRow.implicitWidth + Styles.marginSm * 3

    RowLayout {
        id: contentRow
        spacing: Styles.marginSm
        anchors.centerIn: parent

        property int aWidth: 150

        TextStyled {
            id: clock
            text: Time.getSymbol() + " " + Time.getTime()
            color: theme.text
            Layout.preferredWidth: contentRow.aWidth
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: contentRow.aWidth / 3
            ButtonStyled {
                id: button
                anchors.fill: parent
                text: Icons.apps
                textColor: theme.text
                defaultColor: theme.background
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        PatchBay.openAppLauncher();
                    } else if (mouse.button === Qt.MiddleButton) {
                        PatchBay.openPowerMenu();
                    } else if (mouse.button === Qt.RightButton) {
                        PatchBay.openMixer();
                    }
                }
            }
        }

        ActionMenu {
            id: calendarButton
            Layout.fillHeight: true
            Layout.preferredWidth: contentRow.aWidth
            text: Time.date + " 󰃭"
            textColor: theme.text
            defaultColor: theme.background
            popupWidth: 340
            popupHeight: calendarContent.implicitHeight + Styles.marginSm * 2
            popupColor: theme.foreground
            popupPadding: Styles.marginSm
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    calendarButton.togglePopup();
                }
            }

            ColumnLayout {
                id: calendarContent
                anchors.fill: parent
                spacing: Styles.marginSm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.marginSm

                    ButtonStyled {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 30
                        text: Icons.back
                        textColor: theme.text
                        defaultColor: theme.background
                        onClicked: root.shiftMonth(-1)
                    }

                    ButtonStyled {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: root.monthTitle()
                        textColor: theme.text
                        defaultColor: theme.background
                        onClicked: root.resetMonth()
                    }

                    ButtonStyled {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 30
                        text: Icons.rightChevron
                        textColor: theme.text
                        defaultColor: theme.background
                        onClicked: root.shiftMonth(1)
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 4
                    rowSpacing: 4

                    Repeater {
                        model: root.dayNames
                        delegate: TextStyled {
                            required property string modelData
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 24
                            text: modelData
                            color: theme.text
                            font.pointSize: Styles.textXs
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Repeater {
                        model: 42
                        delegate: Rectangle {
                            id: dayCell

                            required property int index

                            readonly property var dateValue: root.cellDate(index)
                            readonly property bool inMonth: root.isCurrentMonth(dateValue)
                            readonly property bool isToday: root.sameDay(dateValue, new Date())

                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 34
                            radius: Styles.radiusSm
                            color: isToday ? theme.text : (inMonth ? theme.background : "transparent")
                            border.color: inMonth && !isToday ? theme.text : "transparent"
                            border.width: inMonth && !isToday ? 1 : 0
                            opacity: inMonth ? 1.0 : 0.45

                            TextStyled {
                                anchors.centerIn: parent
                                text: dayCell.dateValue.getDate()
                                color: dayCell.isToday ? theme.background : theme.text
                                font.pointSize: Styles.textSm
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
