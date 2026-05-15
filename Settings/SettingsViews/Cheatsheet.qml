pragma ComponentBehavior: Bound

import Quickshell.Io

import QtQuick
import QtQuick.Controls

import qs.Settings
import qs.Components

Rectangle {
    id: root

    anchors.fill: parent
    color: Colors.surfaceLighter

    Component.onCompleted: forceActiveFocus()


    ScrollView {
        id: mainScrollView
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        contentWidth: availableWidth
        TextStyled {
            id: cheatsheetText
            textFormat: Text.MarkdownText
        }
        Process {
            id: cheatsheetProcess
            running: true
            command: ["cat", "./docs/Cheatsheet.md"]
            stdout: StdioCollector {
                onStreamFinished: cheatsheetText.text = text
            }
        }
    }
}
