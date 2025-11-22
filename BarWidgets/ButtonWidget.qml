import Quickshell
import QtQuick

import qs.Components
import qs.Constants

ButtonStyled {
    id: root

    radius: Styles.radius0
    height: parent.height
    width: parent.height

    property string icon: "*"
    property string command

    TextStyled {
        id: text
        text: root.icon
        anchors.centerIn: parent
    }

    onClicked: {
        Quickshell.execDetached(["bash", "-c", root.command]);
    }
}
