import Quickshell
import QtQuick

PopupWindow {
    id: root

    color: "transparent"

    property bool isOpen: false
    property int interval: 250

    Timer {
        id: timer
        interval: root.interval
        onTriggered: {
            root.visible = false;
        }
    }

    function show() {
        if (!root.isOpen) {
            root.visible = true;
            Qt.callLater(function () {
                root.isOpen = true;
            });
        }
    }

    function hide() {
        if (root.isOpen) {
            root.isOpen = false;
            timer.running = true;
        }
    }

    function toggleVisible() {
        if (root.isOpen) {
            hide();
        } else {
            show();
        }
    }
}
