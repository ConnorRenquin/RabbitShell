import QtQuick

import qs.Components
import qs.Constants
import qs.Services

ButtonStyled {
    id: root

    width: parent.height
    height: parent.height
    radius: Styles.radiusSm

    defaultColor: IdleInhibitorSingleton.enabled() ? Colors.orange : Colors.background
    hoverColor: IdleInhibitorSingleton.enabled() ? Colors.backgroundSuccess : Colors.bg2

    TextStyled {
        anchors.centerIn: parent
        text: IdleInhibitorSingleton.enabled() ? "󰅶" : "󰛊"
    }

    onClicked: IdleInhibitorSingleton.toggle()
}
