pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
import qs.Services

FloatingWindow {
    id: root

    visible: false
    title: 'Clipboard'

    implicitWidth: 600
    implicitHeight: 900
    color: "transparent"

    function exit() {
        root.visible = false;
        grab.active = false;
    }

    Utils {
        id: utils
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
    }

    Rectangle {
        id: base

        anchors.fill: parent

        color: Colors.background
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
                if (isNumberKey && clipboardItems.currentItem) {
                    const itemText = clipboardItems.currentItem.itemText;
                    utils.notify('Storing to slot ' + (keyIndex === 9 ? 0 : keyIndex + 1), itemText);
                    const newSlots = ClipboardService.clipboardData.slots.slice();
                    while (newSlots.length <= keyIndex) {
                        newSlots.push("");
                    }
                    newSlots[keyIndex] = itemText;
                    ClipboardService.clipboardData = {
                        "slots": newSlots,
                        "clipboardText": ClipboardService.clipboardData.clipboardText
                    };
                }
            } else if (altHeld) {
                if (event.key === Qt.Key_D) {
                    utils.notify('Slots Cleared');
                    ClipboardService.clipboardData = {
                        "slots": [],
                        "clipboardText": ClipboardService.clipboardData.clipboardText
                    };
                } else if (isNumberKey) {
                    ClipboardService.checkSlot(keyIndex);
                }
            } else if (isNumberKey) {
                ClipboardService.copySlotToClipboard(keyIndex);
            }
        }

        Keys.onPressed: event => {
            // Handle search activation
            if (event.key === Qt.Key_Slash) {
                searchField.focus = true;
                event.accepted = true;
                return;
            }

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
                if (clipboardItems.currentItem) {
                    clipboardItems.currentItem.clicked(null);
                }
            } else if ([Qt.Key_G].includes(event.key)) {
                clipboardItems.currentIndex = 0;
            } else if ([Qt.Key_D].includes(event.key)) {
                if (clipboardItems.currentItem) {
                    const currentIndex = clipboardItems.currentIndex;
                    const originalIndex = clipboardItems.currentItem.originalIndex;
                    ClipboardService.removeEntry(originalIndex);
                    if (clipboardItems.count > 0) {
                        clipboardItems.currentIndex = Math.min(currentIndex, clipboardItems.count - 1);
                    }
                }
            }
            clipboardItems.positionViewAtIndex(clipboardItems.currentIndex, ListView.Contain);
        }

        ColumnLayout {
            id: mainContent
            anchors.fill: parent

            property string searchText: ""
            property var filteredItems: {
                if (!searchText || searchText.trim() === "") {
                    // Return items with their original indices
                    return ClipboardService.clipboardData.clipboardText.map((text, index) => ({
                                text: text,
                                originalIndex: index
                            }));
                }

                // Create array of items with search scores
                let scoredItems = [];
                for (let i = 0; i < ClipboardService.clipboardData.clipboardText.length; i++) {
                    let item = ClipboardService.clipboardData.clipboardText[i];
                    let result = utils.fuzzySearch(searchText, item);
                    if (result.matches) {
                        scoredItems.push({
                            text: item,
                            score: result.score,
                            originalIndex: i
                        });
                    }
                }

                // Sort by score (higher is better)
                scoredItems.sort((a, b) => b.score - a.score);

                // Return items with text and original index
                return scoredItems;
            }

            Rectangle {
                id: storageSlots
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.margins: Styles.marginSm
                Layout.bottomMargin: 0
                color: Colors.backgroundLifted
                radius: Styles.radiusSm

                RowLayoutPlus {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    model: 10
                    delegate: Item {
                        id: slotButtonContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        required property var modelData

                        ButtonStyled {
                            id: slotButton
                            anchors.fill: parent

                            color: ClipboardService.clipboardData.slots[slotButtonContainer.modelData] && ClipboardService.clipboardData.slots[slotButtonContainer.modelData] !== "" ? Colors.green : Colors.background

                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    ClipboardService.clearSlot(slotButtonContainer.modelData);
                                } else {
                                    ClipboardService.copySlotToClipboard(slotButtonContainer.modelData);
                                }
                            }

                            onContainsMouseChanged: {
                                if (containsMouse && ClipboardService.clipboardData.slots[slotButtonContainer.modelData]) {
                                    slotTooltip.visible = true;
                                } else {
                                    slotTooltip.visible = false;
                                }
                            }

                            TextStyled {
                                anchors.centerIn: parent
                                text: slotButtonContainer.modelData === 9 ? "0" : String(slotButtonContainer.modelData + 1)
                                color: ClipboardService.clipboardData.slots[slotButtonContainer.modelData] && ClipboardService.clipboardData.slots[slotButtonContainer.modelData] !== "" ? Colors.background : Colors.foreground
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
                                color: Colors.backgroundLifted
                                radius: Styles.radiusMd
                                TextStyled {
                                    id: tooltipContent
                                    anchors.fill: parent
                                    anchors.margins: Styles.marginSm
                                    text: utils.removeIndentation(ClipboardService.clipboardData.slots[slotButtonContainer.modelData]) || "Empty"
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    color: Colors.foreground
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 50
                Layout.fillWidth: true
                Layout.margins: Styles.marginSm
                color: Colors.backgroundLifted
                radius: Styles.radiusSm

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm

                    TextFieldStyled {
                        id: searchField
                        placeholderText: 'search (press / to focus)'
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        backgroundColor: Colors.backgroundLifted
                        onTextChanged: mainContent.searchText = text
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                searchField.focus = false;
                                base.focus = true;
                                event.accepted = true;
                            }
                        }
                    }

                    ButtonStyled {
                        id: emojiButton
                        Layout.preferredWidth: 60
                        Layout.fillHeight: true
                        onClicked:  PatchBay.openAsciiEmojis();

                        TextStyled {
                            anchors.centerIn: parent
                            text: "(ᵔᴥᵔ)"
                            color: Colors.foreground
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
                    model: mainContent.filteredItems
                    delegate: ButtonStyled {
                        id: button

                        required property var modelData
                        required property int index

                        implicitHeight: clipboardItemContent.implicitHeight
                        implicitWidth: rect.width
                        radius: Styles.radiusMd

                        defaultColor: Colors.backgroundLifted

                        isFocused: ListView.isCurrentItem

                        property string itemText: modelData.text
                        property int originalIndex: modelData.originalIndex

                        ColumnLayout {
                            id: clipboardItemContent

                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            Rectangle {
                                id: clipboardItemKey
                                Layout.preferredWidth: 80
                                implicitHeight: 20
                                color: Colors.foreground
                                radius: Styles.radiusSm
                                TextStyled {
                                    id: clipboardItemKeyText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    color: Colors.background
                                    anchors.centerIn: parent
                                    text: button.originalIndex === 0 ? "Now" : button.originalIndex
                                }
                            }

                            Rectangle {
                                id: clipboardItemScreen
                                color: Colors.background
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
                                    text: utils.removeIndentation(button.itemText) ?? ''
                                }
                            }
                        }

                        onClicked: event => {
                            const ctrlHeld = event?.modifiers & Qt.ControlModifier;
                            const shiftHeld = event?.modifiers & Qt.ShiftModifier;

                            if (shiftHeld) {
                                ClipboardService.removeEntry(button.originalIndex);
                            } else if (ctrlHeld) {
                                ClipboardService.storeToNextAvailableSlot(button.itemText);
                            } else {
                                const text = button.itemText.replace(/'/g, "'\\''");
                                Quickshell.execDetached(['bash', '-c', "printf '%s' '" + text + "' | wl-copy"]);
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
