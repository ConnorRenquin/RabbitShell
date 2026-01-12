import QtQuick
import QtQuick.Layouts

ColumnLayout {
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property int currentIndex: -1

    readonly property var visibleChildren: {
        let visible = [];
        for (let i = 0; i < children.length; i++) {
            let child = children[i];
            if (child && child.visible !== false && child.width > 0 && child.height > 0) {
                visible.push(child);
            }
        }
        return visible;
    }

    readonly property var currentItem: currentIndex >= 0 && currentIndex < visibleChildren.length ? visibleChildren[currentIndex] : null

    function incrementCurrentIndex() {
        if (visibleChildren.length === 0)
            return;
        if (currentIndex < visibleChildren.length - 1) {
            currentIndex++;
        } else {
            currentIndex = 0;
        }
    }

    function decrementCurrentIndex() {
        if (visibleChildren.length === 0)
            return;
        if (currentIndex > 0) {
            currentIndex--;
        } else {
            currentIndex = visibleChildren.length - 1;
        }
    }

    Repeater {
        id: repeater
    }
}
