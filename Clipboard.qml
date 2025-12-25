pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Constants
import qs.Components
import qs.Services

PanelWindow {
    id: root

    Utils {
        id: utils
    }

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

    property var storedClipboard: []

    function exit() {
        root.visible = false;
        grab.active = false;
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/clipboard.json')
        blockLoading: true
        onLoaded: root.storedClipboard = JSON.parse(persistantData.text())
        onLoadFailed: Quickshell.execDetached(['touch', '.data/clipboard.json']) & persistantData.reload()
        onSaveFailed: persistantData.reload()
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

        function slotController(event) {
            let keyIndex = -1;
            if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                keyIndex = event.key - Qt.Key_1;
            } else if (event.key === Qt.Key_0) {
                keyIndex = 9;
            }

            const isNumberKey = keyIndex !== -1 && clipboardItems.currentItem;

            const ctrlHeld = event.modifiers & Qt.ControlModifier;
            const altHeld = event.modifiers & Qt.AltModifier;

            if (ctrlHeld) {
                if (isNumberKey) {
                    utils.notify('Storing to slot ' + (event.key - Qt.Key_0), clipboardItems.currentItem.itemText);
                    const newStored = root.storedClipboard.slice();
                    newStored[keyIndex] = clipboardItems.currentItem.itemText;
                    root.storedClipboard = newStored;
                }
            } else if (altHeld) {
                if (event.key === Qt.Key_D) {
                    console.log('2');
                    utils.notify('Slots Cleared');
                    root.storedClipboard = [];
                } else if (isNumberKey) {
                    const storedText = root.storedClipboard[keyIndex];
                    if (!storedText) {
                        utils.notify('Slot Empty');
                        return;
                    }
                    utils.notify('', storedText);
                }
            } else if (isNumberKey) {
                copySlotToClipboard(keyIndex);
            }
        }

        function copySlotToClipboard(index) {
            const storedText = root.storedClipboard[index];
            if (!storedText) {
                utils.notify('Slot Empty');
                return;
            }
            const text = storedText.replace(/'/g, "'\\''");
            Quickshell.execDetached(['bash', '-c', "printf '%s' '" + text + "' | wl-copy"]);
            utils.notify('Copied');
            root.exit();
        }

        Keys.onPressed: event => {
            // Handle numeric keys for storage/paste
            slotController(event);

            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.exit();
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
                        delegate: ButtonStyled {
                            id: slotButton

                            required property var modelData

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Styles.radiusSm
                            color: root.storedClipboard[modelData] && root.storedClipboard[modelData] !== "" ? Colors.green : Colors.bgDim

                            onClicked: base.copySlotToClipboard(modelData)
                            TextStyled {
                                anchors.centerIn: parent
                                text: slotButton.modelData === 9 ? "0" : String(slotButton.modelData + 1)
                                color: root.storedClipboard[slotButton.modelData] && root.storedClipboard[slotButton.modelData] !== "" ? Colors.bgDim : Colors.fg
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

                        required property var modelData
                        required property int index

                        implicitHeight: clipboardItemContent.implicitHeight
                        implicitWidth: rect.width
                        radius: Styles.radiusMd

                        defaultColor: Colors.bg0

                        focusedColor: Colors.bgGreen

                        isFocused: ListView.isCurrentItem

                        property string itemText

                        Process {
                            running: true
                            command: ["bash", "-c", "clipvault get --index " + button.modelData]
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

                            property string clipboardValue: button.modelData

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
                                    text: button.index === 0 ? "Now" : button.index
                                }
                            }

                            Rectangle {
                                id: clipboardItemScreen
                                color: Colors.bgDim
                                radius: Styles.radiusMd

                                Layout.fillWidth: true
                                Layout.preferredHeight: clipboardText.implicitHeight + Styles.marginSm * 2
                                Layout.maximumHeight: 300
                                Layout.margins: Styles.marginSm

                                TextStyled {
                                    id: clipboardText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    width: clipboardItemScreen.width - Styles.marginSm * 2
                                    anchors.fill: parent
                                    anchors.margins: Styles.marginSm
                                    anchors.centerIn: parent
                                    color: Colors.blue
                                    text: utils.removeIndentation(button.itemText) ?? ''
                                }
                            }
                        }

                        onClicked: {
                            // Assign selection to current clipboard
                            Quickshell.execDetached(['bash', '-c', 'clipvault get --index ' + modelData + ' | wl-copy']);
                            utils.notify('Copied Item');
                            root.exit();
                        }
                    }
                }
            }
        }
    }
}
