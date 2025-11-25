import Quickshell
import QtQuick

import qs.Constants

Item {
    id: root

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight

    property string text
    property int pixelSize: Styles.textMd
    property string primaryColor: Colors.fg
    property string secondaryColor: Colors.bg2
    property int offset: 8
    property var elide: Text.ElideRight

    TextStyled {
        z: 2
        antialiasing: true
        anchors.top: parent.top
        anchors.topMargin: root.clockMargin
        font.pixelSize: root.pixelSize
        elide: root.elide
        color: root.primaryColor
        text: root.text
    }

    TextStyled {
        id: clockText
        z: 1
        elide: root.elide
        antialiasing: true
        anchors.top: parent.top
        anchors.topMargin: root.offset
        font.pixelSize: root.pixelSize
        color: root.secondaryColor
        text: root.text
    }
}
