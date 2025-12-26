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

    visible: false
    anchors.right: true
    margins.right: Styles.marginLg
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: 600
    implicitHeight: 900
    color: "transparent"

    onClipboardDataChanged: {
        if (persistantData.loaded) {
            persistantData.setText(JSON.stringify(root.clipboardData));
        }
    }

    property var clipboardData: {
        "slots": [],
        "clipboardText": []
    }

    function exit() {
        root.visible = false;
        grab.active = false;
    }

    Utils {
        id: utils
    }

    IpcHandler {
        target: "clip"
        function save(text: string) {
            root.clipboardData = {
                "slots": root.clipboardData.slots,
                "clipboardText": [...root.clipboardData.clipboardText, text]
            };
        }
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/clipboard.json')
        blockLoading: true
        onLoaded: {
            const parsedFile = JSON.parse(persistantData.text());
            root.storedClipboard = parsedFile.storedClipboard;
            root.clipboard = paresdFile.clipboard;
        }
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
                    checkSlot(keyIndex);
                }
            } else if (isNumberKey) {
                copySlotToClipboard(keyIndex);
            }
        }

        function checkSlot(index) {
            const storedText = root.storedClipboard[index];
            if (!storedText) {
                utils.notify('Slot Empty');
                return;
            }
            utils.notify('', storedText);
        }

        function findNextEmptySlot() {
            for (let i = 0; i < 10; i++) {
                if (!root.storedClipboard[i] || root.storedClipboard[i] === "") {
                    return i;
                }
            }
            return -1;
        }

        function storeToNextAvailableSlot(text) {
            const nextSlot = findNextEmptySlot();
            if (nextSlot === -1) {
                utils.notify('No Empty Slots Available');
                return;
            }

            const newStored = root.storedClipboard.slice();
            newStored[nextSlot] = text;
            root.storedClipboard = newStored;
            utils.notify('Stored to slot ' + (nextSlot === 9 ? 0 : nextSlot + 1), text);
        }

        function clearSlot(index) {
            if (!root.storedClipboard[index]) {
                utils.notify('Slot Already Empty');
                return;
            }
            const newStored = root.storedClipboard.slice();
            newStored[index] = "";
            root.storedClipboard = newStored;
            utils.notify('Slot ' + (index === 9 ? 0 : index + 1) + ' Cleared');
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

            property string searchText

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
                        delegate: Item {
                            id: slotButtonContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            required property var modelData

                            ButtonStyled {
                                id: slotButton
                                anchors.fill: parent
                                radius: Styles.radiusSm
                                color: root.storedClipboard[slotButtonContainer.modelData] && root.storedClipboard[slotButtonContainer.modelData] !== "" ? Colors.green : Colors.bgDim

                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        base.clearSlot(slotButtonContainer.modelData);
                                    } else {
                                        base.copySlotToClipboard(slotButtonContainer.modelData);
                                    }
                                }

                                onContainsMouseChanged: {
                                    if (containsMouse && root.storedClipboard[slotButtonContainer.modelData]) {
                                        slotTooltip.visible = true;
                                    } else {
                                        slotTooltip.visible = false;
                                    }
                                }

                                TextStyled {
                                    anchors.centerIn: parent
                                    text: slotButtonContainer.modelData === 9 ? "0" : String(slotButtonContainer.modelData + 1)
                                    color: root.storedClipboard[slotButtonContainer.modelData] && root.storedClipboard[slotButtonContainer.modelData] !== "" ? Colors.bgDim : Colors.fg
                                }
                            }

                            PopupWindow {
                                id: slotTooltip
                                visible: false
                                implicitWidth: Math.min(tooltipContent.implicitWidth + Styles.marginSm * 2, 400)
                                implicitHeight: tooltipContent.implicitHeight + Styles.marginSm * 2
                                color: 'transparent'

                                anchor {
                                    item: slotButton
                                    rect.y: slotButton.height + Styles.marginMd
                                    rect.x: slotButton.width / 2 - implicitWidth / 2
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: Colors.bg0
                                    radius: Styles.radiusMd
                                    TextStyled {
                                        id: tooltipContent
                                        anchors.fill: parent
                                        anchors.margins: Styles.marginSm
                                        text: utils.removeIndentation(root.storedClipboard[slotButtonContainer.modelData]) || "Empty"
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        color: Colors.fg
                                    }
                                }
                            }
                        }
                    }
                }
            }

            TextFieldStyled {
                placeholderText: 'search'
                Layout.fillWidth: true
                Layout.margins: Styles.marginSm
                backgroundColor: Colors.bg0
                onTextChanged: {
                    mainContent.searchText = text;
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
                    model: root.clipboardData["clipboardText"]
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
                                    text: utils.removeIndentation(button.modelData) ?? ''
                                }
                            }
                        }

                        onClicked: function (mouse) {
                            const ctrlHeld = mouse.modifiers & Qt.ControlModifier;

                            if (ctrlHeld) {
                                base.storeToNextAvailableSlot(button.itemText);
                            } else {
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
}
