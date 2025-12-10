import Quickshell
import Quickshell.Widgets
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
    anchors.bottom: true
    margins.bottom: Styles.marginLg
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: 700
    implicitHeight: 500
    color: "transparent"

    property var clipboard: []
    property string currentClipboard: ""

    GlobalShortcut {
        name: 'clipboard'
        onPressed: {
            cliphistList.running = true;
            currentClipboardProcess.running = true;
            root.visible = !root.visible;
            grab.active = true;
            base.focus = true;
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        onCleared: root.visible = false
    }

    Process {
        id: cliphistList
        command: ["cliphist", "list"]
        property var buffer: []
        onStarted: {
            buffer = [];
        }
        stdout: SplitParser {
            onRead: line => cliphistList.buffer.push(line)
        }
        onExited: root.clipboard = this.buffer
    }

    Process {
        id: currentClipboardProcess
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
                return;
            } else if ([Qt.Key_G].includes(event.key)) {
                clipboardItems.currentIndex = 0;
            }
            clipboardItems.positionViewAtIndex(clipboardItems.currentIndex, ListView.Contain);
        }

        ColumnLayout {
            id: mainContent
            anchors.fill: parent

            Rectangle {
                id: currentClipboardDisplay
                z: 1

                Layout.fillWidth: true
                Layout.margins: Styles.marginSm

                Layout.preferredHeight: currentClipboardText.implicitHeight + Styles.marginSm * 2
                color: Colors.bgRed
                radius: Styles.radiusMd

                TextStyled {
                    id: currentClipboardText
                    text: " " + root.currentClipboard
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    anchors.centerIn: parent
                    width: parent.width - Styles.marginSm * 2
                    anchors.margins: Styles.marginSm
                }
            }

            ClippingRectangle {
                id: rect
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: Styles.marginSm
                color: "transparent"
                radius: Styles.radiusMd

                ListView {
                    id: clipboardItems
                    anchors.fill: parent
                    spacing: Styles.marginSm
                    model: root.clipboard
                    delegate: ButtonStyled {
                        id: button

                        implicitHeight: clipboardItemContent.implicitHeight
                        implicitWidth: rect.width
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
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
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
                            Quickshell.execDetached(['bash', '-c', 'notify-send -a System "Clipboard Copied"']);
                            root.visible = false;
                        }
                    }
                }
            }
        }
    }
}
