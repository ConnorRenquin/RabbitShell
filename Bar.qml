import Quickshell
import QtQuick

PanelWindow {
    implicitHeight: 35
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        spacing: 20

        WorkspacesWidget {}
    }

    // Center section
    Row {
        anchors.centerIn: parent
        spacing: 20
        ClockWidget {}
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10
        spacing: 20
    }
}
