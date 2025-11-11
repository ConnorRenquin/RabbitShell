import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.Components
import qs.Constants

BarWidget {

    implicitWidth: Math.min(title.implicitWidth + Styles.margin * 2, 600)
    clip: true

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

    TextStyled {
        id: title
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Styles.margin
        elide: Text.ElideRight
        text: getTitle()
    }
}
