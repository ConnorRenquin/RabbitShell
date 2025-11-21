import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls

import qs.Constants
import qs.Components

PanelWindow {
    id: root

    visible: false
    anchors.right: true
    margins.right: Styles.marginMd
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: base.implicitWidth
    implicitHeight: base.implicitHeight
    color: "transparent"

    property var clipboard: []
    property string currentClipboard: ""

    GlobalShortcut {
        name: 'clipboard'
        onPressed: {
            root.visible = !root.visible;
        }
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
        onCleared: {
            root.visible = false;
        }
    }

    onVisibleChanged: {
        if (visible) {
            cliphistList.buffer = [];
            base.selectedEntryIndex = 0;
            cliphistList.running = true;
            scrollView.ScrollBar.vertical.position = 0;
            currentClipboardProcess.running = true;
        }
    }

    function scrollToIndex(index) {
        var item = column.children[index];
        if (item) {
            var itemY = item.y;
            var itemHeight = item.height;
            var viewHeight = scrollView.height;
            var contentHeight = column.height;

            // Calculate position to center the item
            var targetY = itemY - (viewHeight - itemHeight) / 2;
            targetY = Math.max(0, Math.min(targetY, contentHeight - viewHeight));

            // Set the content position directly
            scrollView.contentItem.contentY = targetY;
        }
    }

    Process {
        id: cliphistList
        running: true
        command: ["cliphist", "list"]

        property var buffer: []

        stdout: SplitParser {
            onRead: line => {
                cliphistList.buffer.push(line);
            }
        }
        onExited: root.clipboard = this.buffer
    }

    Process {
        id: currentClipboardProcess
        running: false
        command: ["wl-paste", "-n"]

        stdout: SplitParser {
            onRead: line => {
                root.currentClipboard = line.replace(/^\s+/, '');
            }
        }
    }

    Rectangle {
        id: base
        implicitWidth: 500
        implicitHeight: 800
        color: Colors.bgDim
        radius: Styles.radiusLg
        focus: true

        property int selectedEntryIndex: 0

        Keys.onPressed: event => {
            if (repeater.count === 0)
                return;

            var newIndex = selectedEntryIndex;

            if (event.key === Qt.Key_N) {
                scrollBar.position += 0.001;
                return;
            } else if (event.key === Qt.Key_Escape) {
                root.visible = false;
                return;
            } else if (event.key === Qt.Key_J || event.key === Qt.Key_Down) {
                newIndex += 1;
            } else if (event.key === Qt.Key_K || event.key === Qt.Key_Up) {
                newIndex -= 1;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                var item = repeater.itemAt(selectedEntryIndex);
                if (item) {
                    item.clicked(null);
                }
                root.visible = false;
                return;
            }

            if (newIndex >= repeater.count) {
                newIndex = 0;
            } else if (newIndex < 0) {
                newIndex = repeater.count - 1;
            }

            var oldItem = repeater.itemAt(selectedEntryIndex);
            if (oldItem)
                oldItem.isFocused = false;

            selectedEntryIndex = newIndex;
            root.scrollToIndex(selectedEntryIndex);

            var newItem = repeater.itemAt(selectedEntryIndex);
            if (newItem) {
                newItem.isFocused = true;
            }
        }

        Rectangle {
            id: currentClipboardDisplay
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Styles.marginSm
            height: currentClipboardText.implicitHeight + 2 * Styles.marginMd
            color: Colors.bgRed
            radius: Styles.radiusMd

            TextStyled {
                id: currentClipboardText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Styles.marginMd * 2
                anchors.margins: Styles.marginMd
                text: root.currentClipboard
                font.pixelSize: 24
                color: Colors.fg
            }
        }

        ScrollView {
            id: scrollView
            anchors.top: currentClipboardDisplay.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            contentWidth: parent.implicitWidth

            ScrollBar.vertical: ScrollBar {
                id: scrollBar
                interactive: true
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Behavior on position {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Column {
                id: column
                width: parent.width - 2 * Styles.marginMd
                x: Styles.marginMd
                y: Styles.marginMd
                spacing: Styles.marginSm
                bottomPadding: Styles.marginMd

                Repeater {
                    id: repeater
                    model: root.clipboard

                    ButtonStyled {
                        id: button
                        width: column.width
                        height: text.implicitHeight + 2 * Styles.marginSm
                        radius: Styles.radiusMd

                        defaultColor: Colors.bg0
                        focusedColor: Colors.aqua

                        isFocused: index === 0

                        Component.onCompleted: {
                            if (index === 0)
                                isFocused = true;
                        }

                        TextStyled {
                            id: text
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - Styles.marginMd * 2
                            anchors.margins: Styles.marginMd
                            wrapMode: Text.WordWrap
                            elide: Text.ElideNone
                            text: modelData
                            color: button.isFocused ? Colors.bgDim : Colors.fg
                        }

                        onClicked: {
                            Quickshell.execDetached(['bash', '-c', 'echo \'' + modelData + '\' | cliphist decode | wl-copy']);
                            root.visible = false;
                        }
                    }
                }
            }
        }
    }
}
