import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Components
import qs.Constants
import qs.Services

ButtonStyled {
    id: root

    width: parent.height
    height: parent.height
    radius: Styles.radius0
    color: IdleInhibitorSingleton.enabled ? Colors.orange : Colors.bgDim

    TextStyled {
        anchors.centerIn: parent
        text: IdleInhibitorSingleton.enabled ? "󰅶" : "󰛊"
    }

    onClicked: IdleInhibitorSingleton.enabled = !IdleInhibitorSingleton.enabled
}
