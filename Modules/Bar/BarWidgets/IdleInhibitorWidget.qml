import QtQuick

import qs.Components
import qs.Components.Styled
import qs.Settings
import qs.Services

ButtonStyled {
    id: root

    implicitWidth: parent.height
    implicitHeight: parent.height

    TextStyled {
        anchors.centerIn: parent
        text: IdleInhibitorSingleton.enabled() ? "󰅶" : "󰛊"
    }

    onClicked: IdleInhibitorSingleton.toggle()
}
