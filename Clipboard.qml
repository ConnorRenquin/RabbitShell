import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
            onRead: line => cliphistList.buffer.push(line)
        }
        onExited: root.clipboard = this.buffer
    }

    Process {
        id: currentClipboardProcess
        running: false
        command: ["wl-paste", "-n"]

        stdout: SplitParser {
            onRead: line => root.currentClipboard = line.replace(/^\s+/, '')
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
            if (clipboardItems.count === 0)
                return;
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.visible = false;
                return;
            } else if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                clipboardItems.incrementCurrentIndex();
            } else if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                clipboardItems.decrementCurrentIndex();
            } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                clipboardItems.currentItem.clicked(null);
                root.visible = false;
            }
        }

        ColumnLayout {
            anchors.fill: parent

            Rectangle {
                id: currentClipboardDisplay
                z: 1

                Layout.fillWidth: true
                Layout.margins: Styles.marginSm

                implicitHeight: currentClipboardText.implicitHeight + Styles.marginMd
                color: Colors.bgRed
                radius: Styles.radiusMd

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
                z: 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: Styles.marginSm

                ListView {
                    id: clipboardItems
                    spacing: Styles.marginSm
                    model: root.clipboard
                    delegate: ButtonStyled {
                        id: button

                        implicitHeight: text.implicitHeight + Styles.marginSm
                        implicitWidth: scrollView.width
                        radius: Styles.radiusMd

                        defaultColor: Colors.bg0
                        focusedColor: Colors.aqua

                        isFocused: ListView.isCurrentItem

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
