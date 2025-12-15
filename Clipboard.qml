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

    onStoredClipboardChanged: {
        if (persistantData.loaded)
            persistantData.setText(JSON.stringify(storedClipboard));
    }

    property var storedClipboard: [null, null, null, null, null, null, null, null, null, null]

    function notify(summary, body = '') {
        var test = Quickshell.execDetached(['notify-send', '-a', 'Clipboard', summary, body]);
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/clipboard.json')
        blockLoading: true
        onLoaded: storedClipboard = JSON.parse(persistantData.text())
    }

    GlobalShortcut {
        name: 'clipboard'
        onPressed: {
            root.visible = !root.visible;
            grab.active = root.visible;
            base.focus = root.visible;
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
            // Handle numeric keys for storage/paste
            const numericKeys = [Qt.Key_1, Qt.Key_2, Qt.Key_3, Qt.Key_4, Qt.Key_5, Qt.Key_6, Qt.Key_7, Qt.Key_8, Qt.Key_9, Qt.Key_0];
            const keyIndex = numericKeys.indexOf(event.key);

            if (keyIndex !== -1) {
                if (event.modifiers & Qt.AltModifier) {
                    // Alt + Number: Store current selected item's text
                    if (clipboardItems.currentIndex >= 0 && clipboardItems.currentIndex < clipboardItems.count && clipboardItems.currentItem) {
                        var newStored = root.storedClipboard.slice();
                        newStored[keyIndex] = clipboardItems.currentItem.itemText;
                        root.storedClipboard = newStored;
                        notify('Stored to slot', clipboardItems.currentItem.itemText);
                    }
                    event.accepted = true;
                    return;
                } else {
                    if (root.storedClipboard[keyIndex] !== null && root.storedClipboard[keyIndex] !== "") {
                        const text = root.storedClipboard[keyIndex].replace(/'/g, "'\\''");
                        Quickshell.execDetached(['bash', '-c', "printf '%s' '" + text + "' | wl-copy"]);
                        root.visible = false;
                        grab.active = false;
                        notify('Copied', text);
                    } else {
                        notify('Slot Empty');
                    }
                    event.accepted = true;
                    return;
                }
            }

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

            Rectangle {
                id: storageSlots
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.margins: Styles.marginSm
                Layout.bottomMargin: 0
                color: Colors.bg0
                radius: Styles.radiusSm

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm

                    Repeater {
                        model: 10
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Styles.radiusSm
                            color: root.storedClipboard[index] !== null && root.storedClipboard[index] !== "" ? Colors.green : Colors.bgDim
                            TextStyled {
                                anchors.centerIn: parent
                                text: index === 9 ? "0" : String(index + 1)
                                color: root.storedClipboard[index] !== null && root.storedClipboard[index] !== "" ? Colors.bgDim : Colors.fg
                                font.bold: root.storedClipboard[index] !== null && root.storedClipboard[index] !== ""
                            }
                        }
                    }
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
                    model: 200
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
                                    text: index === 0 ? "Now" : clipboardItems.model - index + 1 // Equation is to flip from 0 - N to N - 0
                                }
                            }

                            Rectangle {
                                id: clipboardItemScreen
                                color: Colors.bgDim
                                radius: Styles.radiusMd

                                Layout.fillWidth: true
                                Layout.preferredHeight: clipboardText.implicitHeight + Styles.marginSm * 2
                                Layout.margins: Styles.marginSm

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
                            notify('Copied Item');
                            root.visible = false;
                        }
                    }
                }
            }
        }
    }
}
