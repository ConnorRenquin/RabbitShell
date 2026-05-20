pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

import qs.Settings
import qs.Components

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
        utils.notify({summary: 'Entry Removed'});
    }

    function deduplicateClipboardText() {
        const currentClipboardText = root.clipboardData.clipboardText;
        const uniqueClipboardText = [];
        const seen = new Set();

        for (let i = 0; i < currentClipboardText.length; i++) {
            const text = currentClipboardText[i];
            if (!seen.has(text)) {
                seen.add(text);
                uniqueClipboardText.push(text);
            }
        }

        const duplicatesRemoved = currentClipboardText.length - uniqueClipboardText.length;

        root.clipboardData = {
            "slots": root.clipboardData.slots,
            "clipboardText": uniqueClipboardText
        };
    }

    function checkSlot(index) {
        const storedText = root.clipboardData.slots[index];
        if (!storedText) {
            utils.notify({summary: 'Slot Empty'});
            return;
        }
        utils.notify({summary: '', body: storedText});
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
            utils.notify({summary: 'No Empty Slots Available'});
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
        utils.notify({summary: 'Stored to slot ' + (nextSlot === 9 ? 0 : nextSlot + 1),body: text});
    }

    function clearSlot(index) {
        if (!root.clipboardData.slots[index]) {
            utils.notify({summary: 'Slot Already Empty'});
            return;
        }
        const newSlots = root.clipboardData.slots.slice();
        newSlots[index] = "";
        root.clipboardData = {
            "slots": newSlots,
            "clipboardText": root.clipboardData.clipboardText
        };
        utils.notify({summary: 'Slot ' + (index === 9 ? 0 : index + 1) + ' Cleared'});
    }

    function copyToClipboard(text: string) {
        Quickshell.execDetached(['bash', '-c', "printf '%s' '" + text + "' | wl-copy"]);
        utils.notify({
            summary: 'Copied',
            body: text
        });
    }

    function copySlotToClipboard(index) {
        const storedText = root.clipboardData.slots[index];
        if (!storedText) {
            utils.notify({summary: 'Slot Empty'});
            return;
        }
        const text = storedText.replace(/'/g, "'\\''");
        copyToClipboard(text)
    }

    Utils {
        id: utils
    }

    onClipboardDataChanged: {
        if (persistantData.loaded) {
            persistantData.save(root.clipboardData);
        }
    }

    FileViewPlus {
        id: persistantData
        path: Qt.resolvedUrl('./.data/clipboard.json')
        defaultValue: ({
            "slots": [],
            "clipboardText": []
        })

        onDataLoaded: parsedFile => {
            root.clipboardData = {
                "slots": parsedFile.slots || [],
                "clipboardText": parsedFile.clipboardText || []
            };
        }
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

            if (text.length === 1) {
                const charCode = text.charCodeAt(0);
                // Allow if in Private Use Area (E000-F8FF) which includes Nerd Font symbols
                if (charCode < 0xE000 || charCode > 0xF8FF) {
                    return;
                }
            }

            let newClipboardText = [text, ...root.clipboardData.clipboardText];

            // Limit the number of entries, removing oldest ones
            var clipboardLimit = Settings.get('clipboardLimit').value
            if (clipboardLimit && newClipboardText.length > root.clipboardLimit) {
                console.log('hi')
                newClipboardText = newClipboardText.slice(0, root.clipboardLimit + 1);
            }

            root.clipboardData = {
                "slots": root.clipboardData.slots,
                "clipboardText": newClipboardText
            };

            root.deduplicateClipboardText()
        }
    }
}
