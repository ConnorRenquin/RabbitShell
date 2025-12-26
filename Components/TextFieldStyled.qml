import QtQuick
import QtQuick.Controls

import qs.Constants

TextField {
    id: root

    property string backgroundColor: Colors.bgDim

    font.pixelSize: Styles.textMd
    color: Colors.fg
    selectByMouse: true
    cursorVisible: true
    focus: true
    verticalAlignment: TextInput.AlignVCenter
    placeholderTextColor: Colors.fg
    background: Rectangle {
        color: root.backgroundColor
        radius: Styles.radiusSm
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: root.forceActiveFocus()
    }
}
