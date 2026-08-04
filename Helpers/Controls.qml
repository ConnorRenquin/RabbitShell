import Quickshell
import QtQuick

Item {
    width: 0
    height: 0

    function enterPressed(event) {
        return [Qt.Key_Return, Qt.Key_Enter].includes(event.key);
    }

    function escapePressed(event) {
        return event.key === Qt.Key_Escape;
    }

    // Escape or Q
    function quitPressed(event) {
        return [Qt.Key_Escape, Qt.Key_Q].includes(event.key);
    }

    function upPressed(event, ctrlRequired = false) {
        if (event.key === Qt.Key_Up) return true;
        if (event.key === Qt.Key_K) {
            if (ctrlRequired) {
                return (event.modifiers & Qt.ControlModifier) !== 0;
            }
            return true;
        }
        return false;
    }

    function downPressed(event, ctrlRequired = false) {
        if (event.key === Qt.Key_Down) return true;
        if (event.key === Qt.Key_J) {
            if (ctrlRequired) {
                return (event.modifiers & Qt.ControlModifier) !== 0;
            }
            return true;
        }
        return false;
    }

    function leftPressed(event, ctrlRequired = false) {
        if (event.key === Qt.Key_Left) return true;
        if (event.key === Qt.Key_H) {
            if (ctrlRequired) {
                return (event.modifiers & Qt.ControlModifier) !== 0;
            }
            return true;
        }
        return false;
    }

    function rightPressed(event, ctrlRequired = false) {
        if (event.key === Qt.Key_Right) return true;
        if (event.key === Qt.Key_L) {
            if (ctrlRequired) {
                return (event.modifiers & Qt.ControlModifier) !== 0;
            }
            return true;
        }
        return false;
    }

    function tabPressed(event) {
        return event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier);
    }

    function backtabPressed(event) {
        return event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier));
    }

    function slashPressed(event) {
        return event.key === Qt.Key_Slash;
    }

    function mPressed(event) {
        return event.key === Qt.Key_M;
    }

    function cPressed(event) {
        return event.key === Qt.Key_C;
    }

    function preferredLabel(primary, fallback, unknownLabel = "Unknown") {
        return primary || fallback || unknownLabel;
    }

    function hotkeyLabel(value, fallback = "unknown") {
        return String(value || fallback).toLowerCase().replace(/[^a-z]/g, '') || fallback;
    }

    function generateHotkey(value, assigned, fallback = "unknown") {
        const name = hotkeyLabel(value, fallback);
        const taken = key => assigned.some(entry => entry.hotkey === key);

        for (let length = 1; length <= Math.min(2, name.length); length++) {
            const prefix = name.substring(0, length);
            if (!taken(prefix))
                return prefix;
        }

        const base = name.substring(0, Math.min(2, name.length));
        for (let index = 0; index < 26; index++) {
            const candidate = base + String.fromCharCode(97 + index);
            if (!taken(candidate))
                return candidate;
        }

        return name.substring(0, 3) || fallback.substring(0, 3);
    }

    function resolveTypedHotkey(character, typedKeys, hotkeys, items) {
        let nextTypedKeys = typedKeys + character;
        let match = hotkeys.find(entry => entry.hotkey === nextTypedKeys);
        let ambiguous = hotkeys.some(entry => entry.hotkey !== nextTypedKeys && entry.hotkey.startsWith(nextTypedKeys));

        if (match) {
            return {
                typedKeys: ambiguous ? nextTypedKeys : "",
                index: items.indexOf(match.toplevel)
            };
        }

        if (!hotkeys.some(entry => entry.hotkey.startsWith(nextTypedKeys))) {
            nextTypedKeys = character;
            match = hotkeys.find(entry => entry.hotkey === nextTypedKeys);
            ambiguous = hotkeys.some(entry => entry.hotkey !== nextTypedKeys && entry.hotkey.startsWith(nextTypedKeys));
            if (match) {
                return {
                    typedKeys: ambiguous ? nextTypedKeys : "",
                    index: items.indexOf(match.toplevel)
                };
            }
        }

        return { typedKeys: nextTypedKeys, index: -1 };
    }

    function matchedHotkeyPart(typedKeys, hotkey) {
        return typedKeys !== "" && hotkey.startsWith(typedKeys) ? typedKeys : "";
    }

    function unmatchedHotkeyPart(typedKeys, hotkey) {
        const matched = matchedHotkeyPart(typedKeys, hotkey);
        return matched !== "" ? hotkey.substring(matched.length) : hotkey;
    }
}
