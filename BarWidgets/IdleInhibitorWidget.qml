import QtQuick

import qs.Components
import qs.Settings
import qs.Services

ButtonStyled {
    id: root

    implicitWidth: parent.height
    implicitHeight: parent.height

    defaultColor: IdleInhibitorSingleton.enabled() ? Colors.orange : Colors.background
    hoverColor: IdleInhibitorSingleton.enabled() ? Colors.backgroundSuccess : Colors.backgroundHighlighted

    TextStyled {
        anchors.centerIn: parent
        text: IdleInhibitorSingleton.enabled() ? "󰅶" : "󰛊"
    }

    onClicked: IdleInhibitorSingleton.toggle()
}
