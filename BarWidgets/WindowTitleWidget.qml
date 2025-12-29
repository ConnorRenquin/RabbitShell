import Quickshell.Wayland
import QtQuick

import qs.Components
import qs.Constants

Rectangle {
    clip: true

    radius: Styles.radiusSm
    color: Colors.background

    implicitWidth: Math.min(title.implicitWidth + Styles.margin * 2, 600)
    implicitHeight: parent.height

    function getTitle() {
        var title = ToplevelManager.activeToplevel?.title;

        if (!title) {
            return 'Desktop';
        }

        if (title.includes(' — ')) {
            return title.split(' — ').pop();
        }

        return title.split(' - ').pop();
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 100
        }
    }

    DoubleText {
        id: title
        offset: Styles.barTextOffset
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Styles.margin
        text: getTitle()
    }
}
