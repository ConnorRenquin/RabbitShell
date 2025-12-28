import QtQuick
import QtQuick.Controls

import qs.Constants

TextField {
    id: root

    property string backgroundColor: Colors.backgroundDim

    font.pixelSize: Styles.textMd
    color: Colors.foreground
    selectByMouse: true
    cursorVisible: true
    focus: true
    verticalAlignment: TextInput.AlignVCenter
    placeholderTextColor: Colors.foreground
    background: Rectangle {
        color: "transparent"
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: root.forceActiveFocus()
    }
}
