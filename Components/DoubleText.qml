pragma ComponentBehavior: Bound

import QtQuick

import qs.Settings

Item {
    id: root

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight
    property string text
    property int pointSize: Styles.textMd
    property string color: Colors.onSurface
    property int offset: 8
    property var elide: Text.ElideRight
    property var horizontalAlignment: Qt.AlignHCenter

    component TextStyledLocal: TextStyled {
        anchors.left: parent.left
        anchors.right: parent.right
        elide: root.elide
        font.pointSize: root.pointSize
        horizontalAlignment: root.horizontalAlignment
    }


    TextStyledLocal {
        z: 2
        y: root.offset / 2 * -1
        font.pointSize: root.pointSize
        color: root.color
        text: root.text
    }

    TextStyledLocal {
        id: clockText
        z: 1
        y: root.offset / 2
        color: Qt.darker(root.color, Colors.darker)
        text: root.text
    }
}
