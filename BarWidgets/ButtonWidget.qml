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

    // TODO Switch over to svg at some point?
    TextStyled {
        id: text
        text: icon
        anchors.centerIn: parent
    }

    onClicked: {
        Quickshell.execDetached(["bash", "-c", root.command]);
    }
}
