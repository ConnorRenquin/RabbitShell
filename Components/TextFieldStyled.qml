import QtQuick
import QtQuick.Controls

import qs.Settings

TextField {
    id: root

    property string backgroundColor: Colors.surface

    font.pointSize: Styles.textMd
    color: Colors.onBackground
    selectByMouse: true
    verticalAlignment: TextInput.AlignVCenter
    placeholderTextColor: Colors.onBackground
    background: Rectangle {
        color: "transparent"
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: root.forceActiveFocus()
    }
}
