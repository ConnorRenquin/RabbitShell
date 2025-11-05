import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.Global

BarWidget {
    implicitWidth: title.width + 20
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutQuad
        }
    }

    TextStyled {
        id: title
        anchors.centerIn: parent
        text: ToplevelManager.activeToplevel.title ?? "Desktop"
        wrapMode: Text.NoWrap
    }
}
