import QtQuick
import QtQuick.Controls

import qs.Settings

TextField {
    id: root

    property string backgroundColor: Colors.background

    font.pixelSize: Styles.textMd
    color: Colors.foreground
    selectByMouse: true
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
