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
        spacing: 20

        WorkspacesWidget {}
    }

    Row {
        anchors.centerIn: parent
        spacing: 20
        ClockWidget {}
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: rowMargin
        spacing: 20

        SystemTray {}
        PowerButton {}
    }
}
