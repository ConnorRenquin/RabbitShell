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

    implicitWidth: 400
    implicitHeight: 900
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
            base.focus = !base.focus;
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

        anchors.fill: parent

        color: Colors.bgDim
        radius: Styles.radiusSm

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
            id: mainContent
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
                    anchors.left: parent.left
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

                        implicitHeight: clipboardItemContent.implicitHeight
                        // TODO Bug? Sometimes parent is null?
                        implicitWidth: parent.width
                        radius: Styles.radiusMd

                        defaultColor: Colors.bg0

                        focusedColor: Colors.bgGreen

                        isFocused: ListView.isCurrentItem

                        ColumnLayout {
                            id: clipboardItemContent
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            // TODO Bug? What if there's 2/1/5?
                            property string keyValue: modelData.substring(0, 4)
                            property string clipboardValue: modelData.substring(5)

                            Rectangle {
                                id: clipboardItemKey
                                Layout.preferredWidth: 80
                                implicitHeight: 20
                                color: Colors.orange
                                radius: Styles.radiusSm
                                TextStyled {
                                    id: clipboardItemKeyText
                                    wrapMode: Text.WordWrap
                                    color: Colors.bgDim
                                    anchors.centerIn: parent
                                    text: clipboardItemContent.keyValue
                                }
                            }

                            Rectangle {
                                color: Colors.bgDim
                                radius: Styles.radiusMd

                                Layout.fillWidth: true
                                Layout.preferredHeight: clipboardText.implicitHeight + Styles.marginSm * 2
                                Layout.margins: Styles.marginSm

                                TextStyled {
                                    id: clipboardText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    width: parent.width - Styles.marginSm
                                    anchors.centerIn: parent
                                    color: Colors.blue
                                    text: clipboardItemContent.clipboardValue
                                }
                            }
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
