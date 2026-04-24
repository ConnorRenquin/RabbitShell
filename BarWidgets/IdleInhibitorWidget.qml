import QtQuick

import qs.Components
import qs.Settings
import qs.Services

ButtonStyled {
    id: root

    implicitWidth: parent.height
    implicitHeight: parent.height

    defaultColor: IdleInhibitorSingleton.enabled() ?  Colors.surfaceLighter : Colors.surface
    hoverColor: IdleInhibitorSingleton.enabled() ? Colors.surfaceDarker : Colors.surfaceLighter

    TextStyled {
        anchors.centerIn: parent
        text: IdleInhibitorSingleton.enabled() ? "󰅶" : "󰛊"
    }

    onClicked: IdleInhibitorSingleton.toggle()
}
