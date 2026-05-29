pragma Singleton

import Quickshell
import Quickshell.Io

import QtCore as QtCoreLib
import QtQuick

import qs.Settings
import qs.Helpers
import qs.Components

Singleton {
    id: root

    function init() {
        console.log('ClipboardService -----------------------------------------');
        root.logClipboardWatcher('image directory: ' + root.clipboardImageDirectory);
    }

    property bool clipboardWatchersEnabled: true
    readonly property string clipboardImageDirectory: String(QtCoreLib.StandardPaths.writableLocation(QtCoreLib.StandardPaths.HomeLocation)).replace(/^file:\/\//, "") + "/Pictures/clipboard"
    readonly property string clipboardImageWatcherScript: [
        'dir="$1"',
        'echo "[ClipboardService image] fired state=${CLIPBOARD_STATE:-unset} dir=$dir" >&2',
        'mkdir -p "$dir" || { echo "[ClipboardService image] mkdir failed: $dir" >&2; exit 1; }',
        'target="$dir/$(date +%F-%H-%M-%S).png"',
        'echo "[ClipboardService image] saving to $target" >&2',
        'wl-paste --type image > "$target"',
        'status=$?',
        'size=$(wc -c < "$target" 2>/dev/null || printf 0)',
        'echo "[ClipboardService image] wl-paste exit=$status size=$size" >&2',
        'if [ "$status" -ne 0 ] || [ "$size" -eq 0 ]; then',
        '    echo "[ClipboardService image] removing failed or empty file: $target" >&2',
        '    rm -f "$target"',
        '    exit "$status"',
        'fi'
    ].join("\n")

    function logClipboardWatcher(message) {
        console.log('[ClipboardService watcher]', message);
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

    property var pasteCallbacks: []

    function copyToClipboard(text, notify) {
        Quickshell.execDetached(['bash', '-c', 'printf %s "$1" | wl-copy', 'ClipboardService.copyToClipboard', String(text)]);
        if (notify !== false) {
            utils.notify({
                summary: 'Copied',
                body: text
            });
        }
    }

    function pasteFromClipboard(callback) {
        if (wlPasteProcess.running) {
            return;
        }

        root.pasteCallbacks = [callback];
        wlPasteProcess.running = true;
    }

    function copySlotToClipboard(index) {
        const storedText = root.clipboardData.slots[index];
        if (!storedText) {
            utils.notify({summary: 'Slot Empty'});
            return;
        }
        copyToClipboard(storedText)
    }

    Process {
        id: wlPasteProcess
        command: ['wl-paste', '--no-newline']
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const pastedText = this.text;
                const callbacks = root.pasteCallbacks.slice();
                root.pasteCallbacks = [];

                for (let i = 0; i < callbacks.length; i++) {
                    if (callbacks[i]) {
                        callbacks[i](pastedText);
                    }
                }
            }
        }

    }

    Process {
        id: clipboardTextWatcher
        running: root.clipboardWatchersEnabled
        command: ['wl-paste', '--type', 'text', '--watch', 'sh', '-c', 'qs ipc call clip save "$(wl-paste --type text)"']

        onStarted: root.logClipboardWatcher('text watcher started pid=' + processId)

        function onExited(exitCode) {
            root.logClipboardWatcher('text watcher exited code=' + exitCode);
        }

        onRunningChanged: {
            root.logClipboardWatcher('text watcher running=' + running);
            if (!running && root.clipboardWatchersEnabled) {
                running = true;
            }
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: function(data) {
                if (data.trim() !== "") {
                    root.logClipboardWatcher('text stderr: ' + data.trim());
                }
            }
        }
    }

    Process {
        id: clipboardImageWatcher
        running: root.clipboardWatchersEnabled
        command: ['wl-paste', '--type', 'image', '--watch', 'sh', '-c', root.clipboardImageWatcherScript, 'ClipboardService.imageWatcher', root.clipboardImageDirectory]

        onStarted: root.logClipboardWatcher('image watcher started pid=' + processId)

        function onExited(exitCode) {
            root.logClipboardWatcher('image watcher exited code=' + exitCode);
        }

        onRunningChanged: {
            root.logClipboardWatcher('image watcher running=' + running);
            if (!running && root.clipboardWatchersEnabled) {
                running = true;
            }
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: function(data) {
                if (data.trim() !== "") {
                    root.logClipboardWatcher('image stderr: ' + data.trim());
                }
            }
        }
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
            if (clipboardLimit && newClipboardText.length > clipboardLimit) {
                newClipboardText = newClipboardText.slice(0, clipboardLimit + 1);
            }

            root.clipboardData = {
                "slots": root.clipboardData.slots,
                "clipboardText": newClipboardText
            };

            root.deduplicateClipboardText()
        }
    }
}
