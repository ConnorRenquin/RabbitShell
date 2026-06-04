import Quickshell
import QtQuick
import QtQuick.Controls

import qs.Settings
import qs.Services
import qs.Helpers

TextArea {
    id: textArea

    focus: true
    width: parent.width
    wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
    color: Colors.onBackground
    font.family: Styles.defaultFontFamily
    font.pointSize: Styles.textMd
    selectByMouse: true
    persistentSelection: true

    // Vim Mode Properties
    property bool vimEnabled: false
    property string vimMode: 'NORMAL' // 'NORMAL', 'INSERT', 'VISUAL', or 'VISUAL_LINE'
    property int visualAnchor: -1
    property int visualCursor: -1
    property bool visualForward: true
    property bool gPressed: false
    property bool dPressed: false

    signal requestCycleTab(bool forward)
    signal requestSelectTab(int index)
    signal requestExit()

    Controls {
        id: controls
    }

    Connections {
        target: Settings
        function onSettingsChanged() {
            const s = Settings.settings.find(x => x.name === 'vimModeEnabled');
            if (s) {
                textArea.vimEnabled = s.value;
                if (!s.value) {
                    textArea.vimMode = 'INSERT'; // Fallback to standard insert if disabled
                    textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                }
            }
        }
    }

    Component.onCompleted: {
        const s = Settings.settings.find(x => x.name === 'vimModeEnabled');
        if (s) {
            textArea.vimEnabled = s.value;
            if (s.value) {
                textArea.vimMode = 'NORMAL';
            }
        }
    }

    function getLineStart(pos) {
        let text = textArea.text;
        let start = pos;
        while (start > 0 && text[start - 1] !== '\n') {
            start--;
        }
        return start;
    }

    function getLineEnd(pos) {
        let text = textArea.text;
        let end = pos;
        while (end < text.length && text[end] !== '\n') {
            end++;
        }
        return end;
    }

    function getCursorUpDownPos(down) {
        let pos = textArea.vimMode === 'VISUAL' || textArea.vimMode === 'VISUAL_LINE' ? textArea.visualCursor : textArea.cursorPosition;
        let lineStart = getLineStart(pos);
        let offset = pos - lineStart;

        if (down) {
            let lineEnd = getLineEnd(pos);
            if (lineEnd >= textArea.text.length) return pos; // Already on last line
            let nextLineStart = lineEnd + 1;
            let nextLineEnd = getLineEnd(nextLineStart);
            return Math.min(nextLineEnd, nextLineStart + offset);
        } else {
            if (lineStart === 0) return pos; // Already on first line
            let prevLineEnd = lineStart - 1;
            let prevLineStart = getLineStart(prevLineEnd);
            return Math.min(prevLineEnd, prevLineStart + offset);
        }
    }

    function activeVimPos() {
        return textArea.vimMode === 'VISUAL' || textArea.vimMode === 'VISUAL_LINE' ? textArea.visualCursor : textArea.cursorPosition;
    }

    function isWhitespace(ch) {
        return /\s/.test(ch);
    }

    function isKeywordChar(ch) {
        return /[A-Za-z0-9_]/.test(ch);
    }

    function charClass(ch, bigWord) {
        if (textArea.isWhitespace(ch)) return 0;
        if (bigWord) return 1;
        return textArea.isKeywordChar(ch) ? 1 : 2;
    }

    function getFirstNonBlank(pos) {
        const text = textArea.text;
        let cursor = textArea.getLineStart(pos);
        const end = textArea.getLineEnd(pos);
        while (cursor < end && /[ \t]/.test(text[cursor])) {
            cursor++;
        }
        return cursor;
    }

    function getWordForwardPos(bigWord) {
        bigWord = bigWord === true;
        const text = textArea.text;
        let pos = textArea.activeVimPos();
        if (pos >= text.length) return pos;

        const currentClass = textArea.charClass(text[pos], bigWord);
        if (currentClass !== 0) {
            while (pos < text.length && textArea.charClass(text[pos], bigWord) === currentClass) pos++;
        }
        while (pos < text.length && textArea.isWhitespace(text[pos])) pos++;

        return pos;
    }

    function getWordBackwardPos(bigWord) {
        bigWord = bigWord === true;
        const text = textArea.text;
        let pos = textArea.activeVimPos();
        if (pos <= 0) return pos;

        pos--;
        while (pos > 0 && textArea.isWhitespace(text[pos])) pos--;

        const targetClass = textArea.charClass(text[pos], bigWord);
        while (pos > 0 && textArea.charClass(text[pos - 1], bigWord) === targetClass) pos--;

        return pos;
    }

    function getWordEndPos(bigWord) {
        bigWord = bigWord === true;
        const text = textArea.text;
        let pos = textArea.activeVimPos();
        if (pos >= text.length - 1) return pos;

        pos++;
        while (pos < text.length && textArea.isWhitespace(text[pos])) pos++;
        if (pos >= text.length) return text.length;

        const targetClass = textArea.charClass(text[pos], bigWord);
        while (pos < text.length - 1 && textArea.charClass(text[pos + 1], bigWord) === targetClass) pos++;

        return pos;
    }

    function updateVisualSelection(newPos) {
        newPos = Math.max(0, Math.min(textArea.text.length, newPos));
        textArea.visualCursor = newPos;
        let anchor = textArea.visualAnchor;
        textArea.visualForward = newPos >= anchor;
        if (newPos >= anchor) {
            textArea.select(anchor, Math.min(textArea.text.length, newPos + 1));
        } else {
            textArea.select(Math.min(textArea.text.length, anchor + 1), newPos);
        }
    }

    function updateVisualLineSelection(newPos) {
        newPos = Math.max(0, Math.min(textArea.text.length, newPos));
        textArea.visualCursor = newPos;
        let anchor = textArea.visualAnchor;
        textArea.visualForward = newPos >= anchor;
        let anchorStart = getLineStart(anchor);
        let anchorEnd = getLineEnd(anchor);
        let currentStart = getLineStart(newPos);
        let currentEnd = getLineEnd(newPos);

        if (newPos >= anchor) {
            textArea.select(anchorStart, Math.min(textArea.text.length, currentEnd + 1));
        } else {
            textArea.select(Math.min(textArea.text.length, anchorEnd + 1), currentStart);
        }
    }

    cursorDelegate: Rectangle {
        id: customCursor
        width: textArea.vimEnabled && textArea.vimMode !== 'INSERT' ? Math.max(8, parent.positionToRectangle(parent.cursorPosition).width) : 2
        color: !textArea.vimEnabled ? Colors.onBackground : (textArea.vimMode === 'INSERT' ? Colors.onBackground : (textArea.vimMode === 'NORMAL' ? Colors.primary : "transparent"))
        border.color: textArea.vimEnabled && (textArea.vimMode === 'VISUAL' || textArea.vimMode === 'VISUAL_LINE') ? Colors.tertiary : "transparent"
        border.width: textArea.vimEnabled && (textArea.vimMode === 'VISUAL' || textArea.vimMode === 'VISUAL_LINE') ? 1 : 0
        opacity: textArea.vimEnabled && textArea.vimMode === 'NORMAL' ? 0.6 : 1.0
        transform: Translate {
            x: textArea.vimEnabled && (textArea.vimMode === 'VISUAL' || textArea.vimMode === 'VISUAL_LINE') && textArea.visualForward && textArea.cursorPosition > 0 ? -customCursor.width : 0
        }
        Timer {
            interval: 500
            running: parent.parent.activeFocus && !parent.parent.readOnly
            repeat: true
            onTriggered: parent.visible = !parent.visible
            onRunningChanged: {
                if (!running) parent.visible = true;
            }
        }
    }

    background: Rectangle {
        color: "transparent"
    }

    Keys.onPressed: event => {
        // 1. Global shortcuts (Ctrl+Tab, Ctrl+1-4)
        if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ControlModifier)) {
            if (event.modifiers & Qt.ShiftModifier) {
                textArea.requestCycleTab(false);
            } else {
                textArea.requestCycleTab(true);
            }
            event.accepted = true;
            return;
        }

        if (event.modifiers & Qt.ControlModifier) {
            if (event.key === Qt.Key_1) { textArea.requestSelectTab(0); event.accepted = true; return; }
            if (event.key === Qt.Key_2) { textArea.requestSelectTab(1); event.accepted = true; return; }
            if (event.key === Qt.Key_3) { textArea.requestSelectTab(2); event.accepted = true; return; }
            if (event.key === Qt.Key_4) { textArea.requestSelectTab(3); event.accepted = true; return; }
        }

        // 2. Vim mode handling
        if (textArea.vimEnabled) {
            if (textArea.vimMode === 'INSERT') {
                if (controls.escapePressed(event)) {
                    textArea.vimMode = 'NORMAL';
                    event.accepted = true;
                    return;
                }
                return;
            }

            if (textArea.vimMode === 'VISUAL') {
                if (controls.escapePressed(event)) {
                    textArea.vimMode = 'NORMAL';
                    textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                    event.accepted = true;
                    return;
                }

                event.accepted = true;

                if (textArea.gPressed) {
                    if (event.text === 'g') {
                        textArea.updateVisualSelection(0);
                    }
                    textArea.gPressed = false;
                    return;
                }

                if (event.key === Qt.Key_Left) { textArea.updateVisualSelection(Math.max(0, textArea.visualCursor - 1)); return; }
                if (event.key === Qt.Key_Right) { textArea.updateVisualSelection(Math.min(textArea.text.length, textArea.visualCursor + 1)); return; }
                if (event.key === Qt.Key_Down) { textArea.updateVisualSelection(textArea.getCursorUpDownPos(true)); return; }
                if (event.key === Qt.Key_Up) { textArea.updateVisualSelection(textArea.getCursorUpDownPos(false)); return; }
                if (event.key === Qt.Key_Home) { textArea.updateVisualSelection(textArea.getLineStart(textArea.visualCursor)); return; }
                if (event.key === Qt.Key_End) { textArea.updateVisualSelection(textArea.getLineEnd(textArea.visualCursor)); return; }

                switch (event.text) {
                    // Movement in Visual Mode
                    case 'h':
                        textArea.updateVisualSelection(Math.max(0, textArea.visualCursor - 1));
                        break;
                    case 'l':
                        textArea.updateVisualSelection(Math.min(textArea.text.length, textArea.visualCursor + 1));
                        break;
                    case 'j':
                        textArea.updateVisualSelection(textArea.getCursorUpDownPos(true));
                        break;
                    case 'k':
                        textArea.updateVisualSelection(textArea.getCursorUpDownPos(false));
                        break;
                    case 'w':
                        textArea.updateVisualSelection(textArea.getWordForwardPos());
                        break;
                    case 'W':
                        textArea.updateVisualSelection(textArea.getWordForwardPos(true));
                        break;
                    case 'b':
                        textArea.updateVisualSelection(textArea.getWordBackwardPos());
                        break;
                    case 'B':
                        textArea.updateVisualSelection(textArea.getWordBackwardPos(true));
                        break;
                    case 'e':
                        textArea.updateVisualSelection(textArea.getWordEndPos());
                        break;
                    case 'E':
                        textArea.updateVisualSelection(textArea.getWordEndPos(true));
                        break;
                    case '0':
                        textArea.updateVisualSelection(textArea.getLineStart(textArea.visualCursor));
                        break;
                    case '^':
                        textArea.updateVisualSelection(textArea.getFirstNonBlank(textArea.visualCursor));
                        break;
                    case '$':
                        textArea.updateVisualSelection(textArea.getLineEnd(textArea.visualCursor));
                        break;
                    case 'G':
                        textArea.updateVisualSelection(textArea.text.length);
                        break;
                    case 'g':
                        textArea.gPressed = true;
                        break;

                    // Actions in Visual Mode
                    case 'd':
                    case 'x':
                        let start = textArea.selectionStart;
                        let end = textArea.selectionEnd;
                        textArea.remove(start, end);
                        textArea.vimMode = 'NORMAL';
                        break;
                    case 'y':
                        let yStart = textArea.selectionStart;
                        let yEnd = textArea.selectionEnd;
                        let selectedText = textArea.text.substring(yStart, yEnd);
                        ClipboardService.copyToClipboard(selectedText, false);
                        textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                        textArea.vimMode = 'NORMAL';
                        break;
                    case 'v':
                        textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                        textArea.vimMode = 'NORMAL';
                        break;
                    case 'V':
                        textArea.vimMode = 'VISUAL_LINE';
                        textArea.updateVisualLineSelection(textArea.cursorPosition);
                        break;
                }
                return;
            }

            if (textArea.vimMode === 'VISUAL_LINE') {
                if (controls.escapePressed(event)) {
                    textArea.vimMode = 'NORMAL';
                    textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                    event.accepted = true;
                    return;
                }

                event.accepted = true;

                if (textArea.gPressed) {
                    if (event.text === 'g') {
                        textArea.updateVisualLineSelection(0);
                    }
                    textArea.gPressed = false;
                    return;
                }

                if (event.key === Qt.Key_Down) { textArea.updateVisualLineSelection(textArea.getCursorUpDownPos(true)); return; }
                if (event.key === Qt.Key_Up) { textArea.updateVisualLineSelection(textArea.getCursorUpDownPos(false)); return; }
                if (event.key === Qt.Key_Home) { textArea.updateVisualLineSelection(textArea.getLineStart(textArea.visualCursor)); return; }
                if (event.key === Qt.Key_End) { textArea.updateVisualLineSelection(textArea.getLineEnd(textArea.visualCursor)); return; }

                switch (event.text) {
                    // Movement in Visual Line Mode
                    case 'j':
                        textArea.updateVisualLineSelection(textArea.getCursorUpDownPos(true));
                        break;
                    case 'k':
                        textArea.updateVisualLineSelection(textArea.getCursorUpDownPos(false));
                        break;
                    case 'G':
                        textArea.updateVisualLineSelection(textArea.text.length);
                        break;
                    case 'g':
                        textArea.gPressed = true;
                        break;

                    // Actions in Visual Line Mode
                    case 'd':
                    case 'x':
                        let start = textArea.selectionStart;
                        let end = textArea.selectionEnd;
                        textArea.remove(start, end);
                        textArea.vimMode = 'NORMAL';
                        break;
                    case 'y':
                        let yStart = textArea.selectionStart;
                        let yEnd = textArea.selectionEnd;
                        let selectedText = textArea.text.substring(yStart, yEnd);
                        ClipboardService.copyToClipboard(selectedText, false);
                        textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                        textArea.vimMode = 'NORMAL';
                        break;
                    case 'V':
                        textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                        textArea.vimMode = 'NORMAL';
                        break;
                    case 'v':
                        textArea.vimMode = 'VISUAL';
                        textArea.updateVisualSelection(textArea.cursorPosition);
                        break;
                }

                return;
            }

            // NORMAL mode keybinds
            if (textArea.vimMode === 'NORMAL') {
                event.accepted = true;

                // Handle 'g' prefix
                if (textArea.gPressed) {
                    if (event.text === 'g') {
                        textArea.cursorPosition = 0;
                    }
                    textArea.gPressed = false;
                    return;
                }

                if (event.key === Qt.Key_Left) { textArea.cursorPosition = Math.max(0, textArea.cursorPosition - 1); return; }
                if (event.key === Qt.Key_Right) { textArea.cursorPosition = Math.min(textArea.text.length, textArea.cursorPosition + 1); return; }
                if (event.key === Qt.Key_Down) { textArea.cursorPosition = textArea.getCursorUpDownPos(true); return; }
                if (event.key === Qt.Key_Up) { textArea.cursorPosition = textArea.getCursorUpDownPos(false); return; }
                if (event.key === Qt.Key_Home) { textArea.cursorPosition = textArea.getLineStart(textArea.cursorPosition); return; }
                if (event.key === Qt.Key_End) { textArea.cursorPosition = textArea.getLineEnd(textArea.cursorPosition); return; }

                switch (event.text) {
                    // Movement
                    case 'h':
                        textArea.cursorPosition = Math.max(0, textArea.cursorPosition - 1);
                        break;
                    case 'l':
                        textArea.cursorPosition = Math.min(textArea.text.length, textArea.cursorPosition + 1);
                        break;
                    case 'j':
                        textArea.cursorPosition = textArea.getCursorUpDownPos(true);
                        break;
                    case 'k':
                        textArea.cursorPosition = textArea.getCursorUpDownPos(false);
                        break;
                    case 'w':
                        textArea.cursorPosition = textArea.getWordForwardPos();
                        break;
                    case 'W':
                        textArea.cursorPosition = textArea.getWordForwardPos(true);
                        break;
                    case 'b':
                        textArea.cursorPosition = textArea.getWordBackwardPos();
                        break;
                    case 'B':
                        textArea.cursorPosition = textArea.getWordBackwardPos(true);
                        break;
                    case 'e':
                        textArea.cursorPosition = textArea.getWordEndPos();
                        break;
                    case 'E':
                        textArea.cursorPosition = textArea.getWordEndPos(true);
                        break;
                    case '0':
                        textArea.cursorPosition = textArea.getLineStart(textArea.cursorPosition);
                        break;
                    case '^':
                        textArea.cursorPosition = textArea.getFirstNonBlank(textArea.cursorPosition);
                        break;
                    case '$':
                        textArea.cursorPosition = textArea.getLineEnd(textArea.cursorPosition);
                        break;
                    case 'G':
                        textArea.cursorPosition = textArea.text.length;
                        break;
                    case 'g':
                        textArea.gPressed = true;
                        break;

                    // Mode switching
                    case 'i':
                        textArea.vimMode = 'INSERT';
                        break;
                    case 'a':
                        textArea.cursorPosition = Math.min(textArea.text.length, textArea.cursorPosition + 1);
                        textArea.vimMode = 'INSERT';
                        break;
                    case 'A':
                        textArea.cursorPosition = textArea.getLineEnd(textArea.cursorPosition);
                        textArea.vimMode = 'INSERT';
                        break;
                    case 'I':
                        textArea.cursorPosition = textArea.getFirstNonBlank(textArea.cursorPosition);
                        textArea.vimMode = 'INSERT';
                        break;
                    case 'o':
                        let oEnd = textArea.getLineEnd(textArea.cursorPosition);
                        textArea.insert(oEnd, "\n");
                        textArea.cursorPosition = oEnd + 1;
                        textArea.vimMode = 'INSERT';
                        break;
                    case 'O':
                        let oStart = textArea.getLineStart(textArea.cursorPosition);
                        textArea.insert(oStart, "\n");
                        textArea.cursorPosition = oStart;
                        textArea.vimMode = 'INSERT';
                        break;
                    case 'v':
                        textArea.vimMode = 'VISUAL';
                        textArea.visualAnchor = textArea.cursorPosition;
                        textArea.updateVisualSelection(textArea.cursorPosition);
                        break;
                    case 'V':
                        textArea.vimMode = 'VISUAL_LINE';
                        textArea.visualAnchor = textArea.cursorPosition;
                        textArea.updateVisualLineSelection(textArea.cursorPosition);
                        break;

                    // Editing
                    case 'x':
                        let pos = textArea.cursorPosition;
                        if (pos < textArea.text.length) {
                            textArea.remove(pos, pos + 1);
                        }
                        break;
                    case 'd':
                        if (textArea.dPressed) {
                            let dPos = textArea.cursorPosition;
                            let dStart = textArea.getLineStart(dPos);
                            let dEnd = textArea.getLineEnd(dPos);
                            if (dEnd < textArea.text.length) {
                                textArea.remove(dStart, dEnd + 1);
                            } else if (dStart > 0) {
                                textArea.remove(dStart - 1, dEnd);
                            } else {
                                textArea.remove(dStart, dEnd);
                            }
                            textArea.dPressed = false;
                        } else {
                            textArea.dPressed = true;
                        }
                        break;
                    case 'u':
                        textArea.undo();
                        break;

                    // Paste
                    case 'p':
                        let pPos = textArea.cursorPosition;
                        ClipboardService.pasteFromClipboard(function(pText) {
                            if (pText.length === 0) return;
                            const insertPos = Math.min(textArea.text.length, pPos + 1);
                            textArea.insert(insertPos, pText);
                            textArea.cursorPosition = insertPos + pText.length - 1;
                        });
                        break;
                    case 'P':
                        let PPos = textArea.cursorPosition;
                        ClipboardService.pasteFromClipboard(function(PText) {
                            if (PText.length === 0) return;
                            textArea.insert(PPos, PText);
                            textArea.cursorPosition = PPos + PText.length - 1;
                        });
                        break;

                    default:
                        textArea.dPressed = false;
                        textArea.gPressed = false;

                        if (event.key === Qt.Key_Escape) {
                            textArea.requestExit();
                        }
                        break;
                }
                return;
            }
        } else {
            if (event.key === Qt.Key_Escape) {
                textArea.requestExit();
                event.accepted = true;
            }
        }
    }
}
