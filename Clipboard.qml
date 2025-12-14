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
    anchors.right: true
    margins.right: Styles.marginLg
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: 600
    implicitHeight: 900
    color: "transparent"

    property var clipboard: []
    property string currentClipboard: ""

    GlobalShortcut {
        name: 'clipboard'
        onPressed: {
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

    Rectangle {
        id: base

        anchors.fill: parent

        color: Colors.bgDim
        radius: Styles.radiusSm

        property int selectedEntryIndex: 0

        Keys.onPressed: event => {
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.visible = false;
                grab.active = false;
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
                    model: 100
                    delegate: ButtonStyled {
                        id: button

                        implicitHeight: clipboardItemContent.implicitHeight
                        implicitWidth: rect.width
                        radius: Styles.radiusMd

                        defaultColor: Colors.bg0

                        focusedColor: Colors.bgGreen

                        isFocused: ListView.isCurrentItem

                        property string itemText

                        Process {
                            running: true
                            command: ["bash", "-c", "clipvault get --index " + modelData]
                            stdout: StdioCollector {
                                onStreamFinished: button.itemText = this.text
                            }
                        }

                        ColumnLayout {
                            id: clipboardItemContent
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            property string clipboardValue: modelData

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
                                    text: String(index) // Equation is to flip from 0 - N to N - 0
                                }
                            }

                            Rectangle {
                                id: clipboardItemScreen
                                color: Colors.bgDim
                                radius: Styles.radiusMd

                                Layout.fillWidth: true
                                Layout.preferredHeight: clipboardText.implicitHeight + Styles.marginSm * 2
                                Layout.margins: Styles.marginSm

                                // TODO Make scrolling text?
                                TextStyled {
                                    id: clipboardText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    width: clipboardItemScreen.width - Styles.marginSm * 2
                                    anchors.centerIn: parent
                                    color: Colors.blue
                                    text: {
                                        // Ai code to move text over for indented blocks of copied text.
                                        let lines = button.itemText.split('\n');
                                        let minIndent = Math.min(...lines.filter(line => line.trim().length > 0).map(line => line.match(/^\s*/)[0].length));
                                        return lines.map(line => line.slice(minIndent)).join('\n');
                                    }
                                }
                            }
                        }

                        onClicked: {
                            // Assign selection to current clipboard
                            Quickshell.execDetached(['bash', '-c', 'clipvault get --index ' + modelData + ' | wl-copy']);
                            // Notify
                            Quickshell.execDetached(['bash', '-c', 'notify-send -a System "Clipboard Copied"']);
                            root.visible = false;
                        }
                    }
                }
            }
        }
    }
}
