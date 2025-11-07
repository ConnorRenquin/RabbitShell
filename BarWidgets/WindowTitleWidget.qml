import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.Global
import qs.Constants

BarWidget {

    implicitWidth: title.width + Styles.margin * 2
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
        text: getTitle()
    }
}
