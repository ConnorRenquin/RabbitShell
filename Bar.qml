import Quickshell
import QtQuick

PanelWindow {
    readonly property int rowMargin: 10

    implicitHeight: Constants.barHeight
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: rowMargin
        spacing: rowMargin

        WorkspacesWidget {}
    }

    Row {
        anchors.centerIn: parent
        spacing: rowMargin
        ClockWidget {}
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: rowMargin
        spacing: rowMargin

        SystemTray {}
        IdleInhibitorWidget {}
        PowerButton {}
    }
}
