pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
import qs.Services

Rectangle {
    id: root

    color: "transparent"

    signal requestExit
    signal requestTabCycle(bool forward)

    visible: isActive
    property bool isActive: false

    function navigationHandler(event) {
        if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
            root.requestTabCycle(true);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.requestTabCycle(false);
            event.accepted = true;
            return;
        }
    }

    onIsActiveChanged: {
        if (isActive) {
            base.focus = true;
        }
    }

    Utils {
        id: utils
    }

    Themer {
        id: theme
        variant: 'secondary'
    }

    Rectangle {
        id: base

        anchors.fill: parent
        color: "transparent"

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
                    utils.notify({
                        summary: 'Storing to slot ' + (keyIndex === 9 ? 0 : keyIndex + 1),
                        body: itemText
                    });
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
                    utils.notify({
                        summary: 'Slots Cleared'
                    });
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
            root.navigationHandler(event);
            if (event.key === Qt.Key_Slash) {
                searchField.focus = true;
                event.accepted = true;
                return;
            }

            slotController(event);

            if ([Qt.Key_Down, Qt.Key_J].includes(event.key)) {
                clipboardItems.incrementCurrentIndex();
            } else if ([Qt.Key_Up, Qt.Key_K].includes(event.key)) {
                clipboardItems.decrementCurrentIndex();
            } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                if (clipboardItems.currentItem) {
                    clipboardItems.currentItem.clicked();
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
                    return ClipboardService.clipboardData.clipboardText.map((text, index) => ({
                                text: text,
                                originalIndex: index
                            }));
                }

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

                scoredItems.sort((a, b) => b.score - a.score);

                return scoredItems;
            }

            Rectangle {
                id: storageSlots
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: theme.main
                radius: Styles.radiusSm

                GridLayoutPlus {
                    anchors.fill: parent
                    anchors.margins: Styles.marginXS
                    columns: 5
                    rows: 2
                    model: 10
                    delegate: Item {
                        id: slotButtonContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        required property var modelData

                        ButtonStyled {
                            id: slotButton
                            anchors.fill: parent

                            property bool slotOccupied: (ClipboardService.clipboardData.slots[slotButtonContainer.modelData] && ClipboardService.clipboardData.slots[slotButtonContainer.modelData] !== "") ?? false
                            color: slotOccupied ? theme.mainContainer : theme.onMain

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

                            text: {
                                var number = String(slotButtonContainer.modelData + 1)
                                if (slotButtonContainer.modelData === 9) {
                                    number = 0
                                }
                                var content = ClipboardService.clipboardData['slots'][slotButtonContainer.modelData]
                                if (content) {
                                    content = ' ' + content
                                } else {
                                    content = ''
                                }
                                return number + content;
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
                                color: Colors.background
                                radius: Styles.radiusMd
                                TextStyled {
                                    id: tooltipContent
                                    anchors.fill: parent
                                    anchors.margins: Styles.marginSm
                                    text: utils.removeIndentation(ClipboardService.clipboardData.slots[slotButtonContainer.modelData]) || "Empty"
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    color: Colors.onBackground
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
                color: theme.main
                radius: Styles.radiusSm

                TextFieldStyled {
                    id: searchField
                    placeholderText: '/search'
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    color: theme.onMain
                    placeholderTextColor: theme.onMain
                    onTextChanged: mainContent.searchText = text
                    Keys.onPressed: event => {
                        root.navigationHandler(event);
                        if (event.key === Qt.Key_Escape) {
                            base.focus = true;
                            event.accepted = true;
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
                radius: Styles.radiusSm

                ListView {
                    id: clipboardItems
                    anchors.fill: parent
                    spacing: Styles.marginSm
                    model: mainContent.filteredItems
                    delegate: Item {
                        id: button

                        required property var modelData
                        required property int index

                        property bool isFocused: ListView.isCurrentItem

                        implicitHeight: clipboardItemContent.implicitHeight
                        implicitWidth: rect.width

                        property string itemText: modelData.text
                        property int originalIndex: modelData.originalIndex

                        function clicked() {
                            clipboardItemScreen.clicked(null);
                        }

                        RowLayout {
                            id: clipboardItemContent

                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            Rectangle {
                                id: clipboardItemKey
                                Layout.preferredWidth: 50
                                implicitHeight: 20
                                Layout.fillHeight: true
                                color: button.isFocused ? theme.main : theme.onMain
                                radius: Styles.radiusSm
                                TextStyled {
                                    id: clipboardItemKeyText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    color: !button.isFocused ? theme.main : theme.onMain
                                    anchors.centerIn: parent
                                    text: button.originalIndex === 0 ? "Now" : button.originalIndex + ListView.isCurrentItem
                                }
                            }

                            ButtonStyled {
                                id: clipboardItemScreen
                                radius: Styles.radiusSm

                                isFocused: button.isFocused
                                Layout.fillWidth: true
                                Layout.preferredHeight: clipboardText.implicitHeight + Styles.marginSm * 2
                                Layout.maximumHeight: 300

                                onClicked: event => {
                                    const ctrlHeld = event?.modifiers & Qt.ControlModifier;
                                    const shiftHeld = event?.modifiers & Qt.ShiftModifier;

                                    if (shiftHeld) {
                                        ClipboardService.removeEntry(button.originalIndex);
                                    } else if (ctrlHeld) {
                                        ClipboardService.storeToNextAvailableSlot(button.itemText);
                                    } else {
                                        const text = button.itemText.replace(/'/g, "'\\''");
                                        ClipboardService.copyToClipboard(text);
                                        root.requestExit();
                                    }
                                }

                                TextStyled {
                                    id: clipboardText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    width: clipboardItemScreen.width - Styles.marginSm * 2
                                    color: theme.main
                                    anchors.fill: parent
                                    anchors.margins: Styles.marginSm
                                    anchors.centerIn: parent
                                    text: utils.removeIndentation(button.itemText) ?? ''
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
