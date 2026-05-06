import QtQuick

import qs.Components
import qs.Settings
import qs.Services

ButtonStyled {
    id: root

    implicitWidth: parent.height
    implicitHeight: parent.height

    defaultColor: IdleInhibitorSingleton.enabled() ?  Colors.surfaceLighter : Colors.surface

    TextStyled {
        anchors.centerIn: parent
        text: IdleInhibitorSingleton.enabled() ? "󰅶" : "󰛊"
    }

    onClicked: IdleInhibitorSingleton.toggle()
}
