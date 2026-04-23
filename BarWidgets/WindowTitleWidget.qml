import Quickshell.Wayland
import QtQuick

import qs.Components
import qs.Settings

Rectangle {
    id: root

    radius: Styles.radiusSm
    color: Colors.surface

    implicitWidth: Math.min(windowTitle.implicitWidth + Styles.marginSm * 2, 300)
    implicitHeight: parent.height

    NumberAnimation on implicitWidth {
        duration: 100
    }

    TextStyled {
        id: windowTitle
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        text: ToplevelManager?.activeToplevel?.appId ?? "Desktop"
    }
}
