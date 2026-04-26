import QtQuick

import qs.Settings

Item {
    id: root

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight
    property string text
    property int pointSize: Styles.textMd
    property string primaryColor: Colors.onSurface
    property string secondaryColor: Colors.surfaceLighter
    property int offset: 8
    property var elide: Text.ElideRight

    TextStyled {
        z: 2
        antialiasing: true
        anchors.left: parent.left
        anchors.right: parent.right
        y: root.offset / 2 * -1
        font.pointSize: root.pointSize
        elide: root.elide
        color: root.primaryColor
        text: root.text
    }

    TextStyled {
        id: clockText
        z: 1
        y: root.offset / 2
        anchors.left: parent.left
        anchors.right: parent.right
        elide: root.elide
        antialiasing: true
        font.pointSize: root.pointSize
        color: root.secondaryColor
        text: root.text
    }
}
