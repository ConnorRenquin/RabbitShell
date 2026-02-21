pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    function init() {
        console.log('ClipboardService -----------------------------------------');
    }

    property var clipboardData: {
        "slots": [],
        "clipboardText": []
    }

    function removeEntry(index) {
        const newClipboardText = root.clipboardData.clipboardText.filter((_, i) => i !== index);
        root.clipboardData = {
            "slots": root.clipboardData.slots,
            "clipboardText": newClipboardText
        };
        utils.notify('Entry Removed');
    }

    function checkSlot(index) {
        const storedText = root.clipboardData.slots[index];
        if (!storedText) {
            utils.notify('Slot Empty');
            return;
        }
        utils.notify('', storedText);
    }

    function findNextEmptySlot() {
        for (let i = 0; i < 10; i++) {
            if (!root.clipboardData.slots[i] || root.clipboardData.slots[i] === "") {
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

        const newSlots = root.clipboardData.slots.slice();
        while (newSlots.length <= nextSlot) {
            newSlots.push("");
        }
        newSlots[nextSlot] = text;
        root.clipboardData = {
            "slots": newSlots,
            "clipboardText": root.clipboardData.clipboardText
        };
        utils.notify('Stored to slot ' + (nextSlot === 9 ? 0 : nextSlot + 1), text);
    }

    function clearSlot(index) {
        if (!root.clipboardData.slots[index]) {
            utils.notify('Slot Already Empty');
            return;
        }
        const newSlots = root.clipboardData.slots.slice();
        newSlots[index] = "";
        root.clipboardData = {
            "slots": newSlots,
            "clipboardText": root.clipboardData.clipboardText
        };
        utils.notify('Slot ' + (index === 9 ? 0 : index + 1) + ' Cleared');
    }

    function copySlotToClipboard(index) {
        const storedText = root.clipboardData.slots[index];
        if (!storedText) {
            utils.notify('Slot Empty');
            return;
        }
        const text = storedText.replace(/'/g, "'\\''");
        Quickshell.execDetached(['bash', '-c', "printf '%s' '" + text + "' | wl-copy"]);
        utils.notify('Copied');
    }

    Utils {
        id: utils
    }

    onClipboardDataChanged: {
        if (persistantData.loaded) {
            persistantData.setText(JSON.stringify(root.clipboardData));
        }
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/clipboard.json')
        blockLoading: false
        onLoaded: {
            try {
                const parsedFile = JSON.parse(persistantData.text());
                root.clipboardData = {
                    "slots": parsedFile.slots || [],
                    "clipboardText": parsedFile.clipboardText || []
                };
            } catch (e) {
                console.log('Failed to parse clipboard data:', e);
                root.clipboardData = {
                    "slots": [],
                    "clipboardText": []
                };
            }
        }
        onLoadFailed: {
            Quickshell.execDetached(['touch', '.data/clipboard.json']);
            persistantData.setText(JSON.stringify(root.clipboardData));
        }
        onSaveFailed: console.log('Failed to save clipboard data')
    }

    IpcHandler {
        target: "clip"
        function save(text: string) {
            if (text.trim() === "") {
                return;
            }

            if (root.clipboardData.clipboardText.length > 0 && root.clipboardData.clipboardText[0] === text) {
                return;
            }

            root.clipboardData = {
                "slots": root.clipboardData.slots,
                "clipboardText": [text, ...root.clipboardData.clipboardText]
            };
        }
    }
}
