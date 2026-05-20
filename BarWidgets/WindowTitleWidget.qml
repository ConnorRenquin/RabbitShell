import Quickshell.Wayland
import QtQuick

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root

    radius: Styles.radiusSm
    color: theme.foreground

    implicitWidth: Math.min(windowTitle.implicitWidth + Styles.marginSm * 2, 300)
    implicitHeight: parent.height

    Themer {
        id: theme
        settingName: 'titleColor'
    }

    NumberAnimation on implicitWidth {
        duration: 100
    }

    TextStyled {
        id: windowTitle
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        text: ToplevelManager?.activeToplevel?.appId ?? "Desktop"
        color: theme.text
    }
}
