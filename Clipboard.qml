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

    onVisibleChanged: {
        if (!visible)
            return;
        cliphistList.buffer = [];
        base.selectedEntryIndex = 0;
        scrollView.ScrollBar.vertical.position = 0;
        cliphistList.running = true;
        currentClipboardProcess.running = true;
    }

    property var clipboard: []
    property string currentClipboard: ""

    function scrollToIndex(index) {
        var item = column.children[index];
        if (!item)
            return;

        var itemY = item.y;
        var itemHeight = item.height;
        var viewHeight = scrollView.height;
        var contentHeight = column.height;
        var targetY = itemY - (viewHeight - itemHeight) / 2;

        targetY = Math.max(0, Math.min(targetY, contentHeight - viewHeight));

        scrollView.contentItem.contentY = targetY;
    }

    GlobalShortcut {
        name: 'clipboard'
        onPressed: {
            root.visible = !root.visible;
            grab.active = true;
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        onCleared: root.visible = false
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
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.visible = false;
                return;
            } else if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                newIndex += 1;
            } else if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                newIndex -= 1;
            } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
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

            implicitHeight: currentClipboardText.implicitHeight + Styles.marginMd
            color: Colors.bgRed
            radius: Styles.radiusMd

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Styles.marginSm
            }

            TextStyled {
                id: currentClipboardText
                text: " " + root.currentClipboard
                font.pixelSize: 24
                anchors.margins: Styles.marginMd
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ScrollView {
            id: scrollView

            contentWidth: parent.implicitWidth

            anchors {
                top: currentClipboardDisplay.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

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

                spacing: Styles.marginSm

                anchors {
                    fill: parent
                    margins: Styles.marginMd
                }

                Repeater {
                    id: repeater
                    model: root.clipboard
                    delegate: ButtonStyled {
                        id: button

                        width: column.width
                        height: text.implicitHeight + Styles.marginSm
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

                            wrapMode: Text.WordWrap
                            color: button.isFocused ? Colors.bgDim : Colors.fg

                            anchors.margins: Styles.marginMd
                            anchors.verticalCenter: parent.verticalCenter

                            text: modelData
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
