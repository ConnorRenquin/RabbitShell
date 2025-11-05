import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.Global

BarWidget {
    implicitWidth: title.width + 20
    clip: true

    function getTitle() {
	console.log(ToplevelManager.activeToplevel.title);
	
	var title = ToplevelManager.activeToplevel.title

	if (title.includes(' — ')) {
		return title.split(' — ').pop()
	}

	return title.split(' - ').pop()
    }


    Behavior on implicitWidth {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutQuad
        }
    }

    TextStyled {
        id: title
        anchors.centerIn: parent
        text: getTitle() 
        wrapMode: Text.NoWrap
    }
}
