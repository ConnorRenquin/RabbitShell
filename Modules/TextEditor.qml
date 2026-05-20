pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components
import qs.Services

FloatingWindow {
    id: root

    visible: false
    title: 'Scratchpad Editor'

    implicitWidth: 750
    implicitHeight: 450
    color: "transparent"

    property int currentTab: 0
    property var tabContents: ["", "", "", ""]
    property bool isReady: false

    // Vim Mode Properties
    property bool vimEnabled: false
    property string vimMode: 'NORMAL' // 'NORMAL', 'INSERT', 'VISUAL', or 'VISUAL_LINE'
    property int visualAnchor: -1
    property bool gPressed: false
    property bool dPressed: false

    Connections {
        target: Settings
        function onSettingsChanged() {
            const s = Settings.settings.find(x => x.name === 'vimModeEnabled');
            if (s) {
                root.vimEnabled = s.value;
                if (!s.value) {
                    root.vimMode = 'INSERT'; // Fallback to standard insert if disabled
                    textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                }
            }
        }
    }

    Component.onCompleted: {
        const s = Settings.settings.find(x => x.name === 'vimModeEnabled');
        if (s) {
            root.vimEnabled = s.value;
            if (s.value) {
                root.vimMode = 'NORMAL';
            }
        }
    }

    function exit() {
        root.visible = false;
        grab.active = false;
        saveTabs();
    }

    function show() {
        root.visible = true;
        grab.active = true;
        if (root.vimEnabled) {
            root.vimMode = 'NORMAL';
            textArea.select(textArea.cursorPosition, textArea.cursorPosition);
        }
        textArea.forceActiveFocus();
    }

    function toggle() {
        if (root.visible) {
            root.exit();
        } else {
            root.show();
        }
    }

    function cycleTab(forward: bool) {
        tabContents[currentTab] = textArea.text;
        
        if (forward) {
            currentTab = (currentTab + 1) % 4;
        } else {
            currentTab = (currentTab + 3) % 4;
        }
        
        textArea.text = tabContents[currentTab];
        textArea.forceActiveFocus();
    }

    function selectTab(index: int) {
        if (index < 0 || index >= 4) return;
        tabContents[currentTab] = textArea.text;
        currentTab = index;
        textArea.text = tabContents[currentTab];
        textArea.forceActiveFocus();
    }

    function saveTabs() {
        if (!isReady) return;
        tabContents[currentTab] = textArea.text;
        persistantData.setText(JSON.stringify({
            tabs: tabContents,
            lastActiveTab: currentTab
        }, null, 2));
    }

    // Vim Helper Functions
    function getLineStart(pos) {
        let text = textArea.text;
        let start = text.lastIndexOf('\n', pos - 1);
        return start === -1 ? 0 : start + 1;
    }

    function getLineEnd(pos) {
        let text = textArea.text;
        let end = text.indexOf('\n', pos);
        return end === -1 ? text.length : end;
    }

    function getCursorUpDownPos(down) {
        let text = textArea.text;
        let pos = textArea.cursorPosition;
        let lineStart = getLineStart(pos);
        let lineEnd = getLineEnd(pos);
        let col = pos - lineStart;

        if (down) {
            if (lineEnd >= text.length) return pos;
            let nextLineStart = lineEnd + 1;
            let nextLineEnd = text.indexOf('\n', nextLineStart);
            if (nextLineEnd === -1) nextLineEnd = text.length;
            let nextLineLength = nextLineEnd - nextLineStart;
            return nextLineStart + Math.min(col, nextLineLength);
        } else {
            if (lineStart <= 0) return pos;
            let prevLineEnd = lineStart - 1;
            let prevLineStart = text.lastIndexOf('\n', prevLineEnd - 1);
            prevLineStart = prevLineStart === -1 ? 0 : prevLineStart + 1;
            let prevLineLength = prevLineEnd - prevLineStart;
            return prevLineStart + Math.min(col, prevLineLength);
        }
    }

    function getWordForwardPos() {
        let text = textArea.text;
        let pos = textArea.cursorPosition;
        while (pos < text.length && /\w/.test(text[pos])) pos++;
        while (pos < text.length && /\W/.test(text[pos])) pos++;
        return pos;
    }

    function getWordBackwardPos() {
        let text = textArea.text;
        let pos = textArea.cursorPosition;
        if (pos <= 0) return pos;
        pos--;
        while (pos > 0 && /\W/.test(text[pos])) pos--;
        while (pos > 0 && /\w/.test(text[pos - 1])) pos--;
        return pos;
    }

    function updateVisualSelection(newPos) {
        let anchor = root.visualAnchor;
        if (newPos >= anchor) {
            textArea.select(anchor, Math.min(textArea.text.length, newPos + 1));
        } else {
            textArea.select(Math.min(textArea.text.length, anchor + 1), newPos);
        }
    }

    function updateVisualLineSelection(newPos) {
        let anchor = root.visualAnchor;
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

    GlobalShortcut {
        name: "texteditor"
        onPressed: root.toggle()
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('../Settings/.data/text_editor_tabs.json')
        blockLoading: false

        onLoaded: {
            try {
                const parsed = JSON.parse(persistantData.text());
                if (parsed.tabs && parsed.tabs.length === 4) {
                    root.tabContents = parsed.tabs;
                }
                if (parsed.hasOwnProperty('lastActiveTab')) {
                    root.currentTab = parsed.lastActiveTab;
                }
                textArea.text = root.tabContents[root.currentTab];
            } catch (e) {
                console.log('TextEditor: failed to parse text_editor_tabs.json:', e);
            }
            root.isReady = true;
        }

        onLoadFailed: {
            console.log('TextEditor: text_editor_tabs.json not found, creating...');
            Quickshell.execDetached(['touch', '../Settings/.data/text_editor_tabs.json']);
            persistantData.setText(JSON.stringify({
                tabs: ["", "", "", ""],
                lastActiveTab: 0
            }, null, 2));
            root.isReady = true;
        }
    }

    Rectangle {
        id: base
        anchors.fill: parent
        color: Colors.background
        radius: Styles.radiusSm
        border.color: Colors.outlineVariant
        border.width: 1
        focus: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Header / Tab Bar
            Rectangle {
                id: tabBar
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: Colors.surface
                radius: Styles.radiusSm

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm

                    Repeater {
                        model: 4
                        delegate: ButtonStyled {
                            id: tabButton
                            required property int index
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: (index + 1)
                            isFocused: root.currentTab === index
                            defaultColor: root.currentTab === index ? Colors.primary : Colors.surfaceVariant
                            textColor: root.currentTab === index ? Colors.onPrimary : Colors.onSurface

                            onClicked: {
                                root.selectTab(index);
                            }
                        }
                    }
                }
            }

            // Editor Area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colors.background
                radius: Styles.radiusSm
                clip: true

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: Styles.marginMd
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded

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
                        placeholderText: "Type something here..."
                        placeholderTextColor: Colors.outline

                        background: Rectangle {
                            color: "transparent"
                        }

                        onTextChanged: {
                            if (root.isReady) {
                                root.tabContents[root.currentTab] = text;
                                root.saveTabs();
                            }
                        }

                        Keys.onPressed: event => {
                            // 1. Global shortcuts (Ctrl+Tab, Ctrl+1-4)
                            if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ControlModifier)) {
                                if (event.modifiers & Qt.ShiftModifier) {
                                    root.cycleTab(false);
                                } else {
                                    root.cycleTab(true);
                                }
                                event.accepted = true;
                                return;
                            }

                            if (event.modifiers & Qt.ControlModifier) {
                                if (event.key === Qt.Key_1) { root.selectTab(0); event.accepted = true; return; }
                                if (event.key === Qt.Key_2) { root.selectTab(1); event.accepted = true; return; }
                                if (event.key === Qt.Key_3) { root.selectTab(2); event.accepted = true; return; }
                                if (event.key === Qt.Key_4) { root.selectTab(3); event.accepted = true; return; }
                            }

                            // 2. Vim mode handling
                            if (root.vimEnabled) {
                                if (root.vimMode === 'INSERT') {
                                    if (event.key === Qt.Key_Escape) {
                                        root.vimMode = 'NORMAL';
                                        event.accepted = true;
                                        return;
                                    }
                                    return;
                                }

                                if (root.vimMode === 'VISUAL') {
                                    if (event.key === Qt.Key_Escape) {
                                        root.vimMode = 'NORMAL';
                                        textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                                        event.accepted = true;
                                        return;
                                    }

                                    event.accepted = true;

                                    switch (event.text) {
                                        // Movement in Visual Mode
                                        case 'h':
                                            root.updateVisualSelection(Math.max(0, textArea.cursorPosition - 1));
                                            break;
                                        case 'l':
                                            root.updateVisualSelection(Math.min(textArea.text.length, textArea.cursorPosition + 1));
                                            break;
                                        case 'j':
                                            root.updateVisualSelection(root.getCursorUpDownPos(true));
                                            break;
                                        case 'k':
                                            root.updateVisualSelection(root.getCursorUpDownPos(false));
                                            break;
                                        case 'w':
                                            root.updateVisualSelection(root.getWordForwardPos());
                                            break;
                                        case 'b':
                                            root.updateVisualSelection(root.getWordBackwardPos());
                                            break;
                                        case '0':
                                            root.updateVisualSelection(root.getLineStart(textArea.cursorPosition));
                                            break;
                                        case '$':
                                            root.updateVisualSelection(root.getLineEnd(textArea.cursorPosition));
                                            break;

                                        // Actions in Visual Mode
                                        case 'd':
                                        case 'x':
                                            let start = textArea.selectionStart;
                                            let end = textArea.selectionEnd;
                                            textArea.remove(start, end);
                                            root.vimMode = 'NORMAL';
                                            break;
                                        case 'y':
                                            let yStart = textArea.selectionStart;
                                            let yEnd = textArea.selectionEnd;
                                            let selectedText = textArea.text.substring(yStart, yEnd);
                                            Quickshell.execDetached(["wl-copy", selectedText]);
                                            textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                                            root.vimMode = 'NORMAL';
                                            break;
                                        case 'v':
                                            textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                                            root.vimMode = 'NORMAL';
                                            break;
                                        case 'V':
                                            root.vimMode = 'VISUAL_LINE';
                                            root.updateVisualLineSelection(textArea.cursorPosition);
                                            break;
                                    }
                                    return;
                                }

                                if (root.vimMode === 'VISUAL_LINE') {
                                    if (event.key === Qt.Key_Escape) {
                                        root.vimMode = 'NORMAL';
                                        textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                                        event.accepted = true;
                                        return;
                                    }

                                    event.accepted = true;

                                    switch (event.text) {
                                        // Movement in Visual Line Mode
                                        case 'j':
                                            root.updateVisualLineSelection(root.getCursorUpDownPos(true));
                                            break;
                                        case 'k':
                                            root.updateVisualLineSelection(root.getCursorUpDownPos(false));
                                            break;
                                        case 'G':
                                            root.updateVisualLineSelection(textArea.text.length);
                                            break;
                                        case 'g':
                                            root.gPressed = true;
                                            break;

                                        // Actions in Visual Line Mode
                                        case 'd':
                                        case 'x':
                                            let start = textArea.selectionStart;
                                            let end = textArea.selectionEnd;
                                            textArea.remove(start, end);
                                            root.vimMode = 'NORMAL';
                                            break;
                                        case 'y':
                                            let yStart = textArea.selectionStart;
                                            let yEnd = textArea.selectionEnd;
                                            let selectedText = textArea.text.substring(yStart, yEnd);
                                            Quickshell.execDetached(["wl-copy", selectedText]);
                                            textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                                            root.vimMode = 'NORMAL';
                                            break;
                                        case 'V':
                                            textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                                            root.vimMode = 'NORMAL';
                                            break;
                                        case 'v':
                                            root.vimMode = 'VISUAL';
                                            root.updateVisualSelection(textArea.cursorPosition);
                                            break;
                                    }

                                    // Handle 'g' prefix in Visual Line Mode
                                    if (root.gPressed && event.text !== 'g') {
                                        if (event.text === 'g') {
                                            root.updateVisualLineSelection(0);
                                        }
                                        root.gPressed = false;
                                    }
                                    return;
                                }

                                // NORMAL mode keybinds
                                if (root.vimMode === 'NORMAL') {
                                    event.accepted = true;

                                    // Handle 'g' prefix
                                    if (root.gPressed) {
                                        if (event.text === 'g') {
                                            textArea.cursorPosition = 0;
                                        }
                                        root.gPressed = false;
                                        return;
                                    }

                                    switch (event.text) {
                                        // Movement
                                        case 'h':
                                            textArea.cursorPosition = Math.max(0, textArea.cursorPosition - 1);
                                            break;
                                        case 'l':
                                            textArea.cursorPosition = Math.min(textArea.text.length, textArea.cursorPosition + 1);
                                            break;
                                        case 'j':
                                            textArea.cursorPosition = root.getCursorUpDownPos(true);
                                            break;
                                        case 'k':
                                            textArea.cursorPosition = root.getCursorUpDownPos(false);
                                            break;
                                        case 'w':
                                            textArea.cursorPosition = root.getWordForwardPos();
                                            break;
                                        case 'b':
                                            textArea.cursorPosition = root.getWordBackwardPos();
                                            break;
                                        case '0':
                                            textArea.cursorPosition = root.getLineStart(textArea.cursorPosition);
                                            break;
                                        case '$':
                                            textArea.cursorPosition = root.getLineEnd(textArea.cursorPosition);
                                            break;
                                        case 'G':
                                            textArea.cursorPosition = textArea.text.length;
                                            break;
                                        case 'g':
                                            root.gPressed = true;
                                            break;

                                        // Mode switching
                                        case 'i':
                                            root.vimMode = 'INSERT';
                                            break;
                                        case 'a':
                                            textArea.cursorPosition = Math.min(textArea.text.length, textArea.cursorPosition + 1);
                                            root.vimMode = 'INSERT';
                                            break;
                                        case 'A':
                                            textArea.cursorPosition = root.getLineEnd(textArea.cursorPosition);
                                            root.vimMode = 'INSERT';
                                            break;
                                        case 'I':
                                            textArea.cursorPosition = root.getLineStart(textArea.cursorPosition);
                                            root.vimMode = 'INSERT';
                                            break;
                                        case 'o':
                                            let oEnd = root.getLineEnd(textArea.cursorPosition);
                                            textArea.insert(oEnd, "\n");
                                            textArea.cursorPosition = oEnd + 1;
                                            root.vimMode = 'INSERT';
                                            break;
                                        case 'O':
                                            let oStart = root.getLineStart(textArea.cursorPosition);
                                            textArea.insert(oStart, "\n");
                                            textArea.cursorPosition = oStart;
                                            root.vimMode = 'INSERT';
                                            break;
                                        case 'v':
                                            root.vimMode = 'VISUAL';
                                            root.visualAnchor = textArea.cursorPosition;
                                            root.updateVisualSelection(textArea.cursorPosition);
                                            break;
                                        case 'V':
                                            root.vimMode = 'VISUAL_LINE';
                                            root.visualAnchor = textArea.cursorPosition;
                                            root.updateVisualLineSelection(textArea.cursorPosition);
                                            break;

                                        // Editing
                                        case 'x':
                                            let pos = textArea.cursorPosition;
                                            if (pos < textArea.text.length) {
                                                textArea.remove(pos, pos + 1);
                                            }
                                            break;
                                        case 'd':
                                            if (root.dPressed) {
                                                let dPos = textArea.cursorPosition;
                                                let dStart = root.getLineStart(dPos);
                                                let dEnd = root.getLineEnd(dPos);
                                                if (dEnd < textArea.text.length) {
                                                    textArea.remove(dStart, dEnd + 1);
                                                } else if (dStart > 0) {
                                                    textArea.remove(dStart - 1, dEnd);
                                                } else {
                                                    textArea.remove(dStart, dEnd);
                                                }
                                                root.dPressed = false;
                                            } else {
                                                root.dPressed = true;
                                            }
                                            break;
                                        case 'u':
                                            textArea.undo();
                                            break;

                                        // Paste
                                        case 'p':
                                            let pText = ClipboardService.clipboardData.clipboardText[0] || "";
                                            let pPos = textArea.cursorPosition;
                                            textArea.insert(pPos + 1, pText);
                                            textArea.cursorPosition = pPos + pText.length;
                                            break;
                                        case 'P':
                                            let PText = ClipboardService.clipboardData.clipboardText[0] || "";
                                            let PPos = textArea.cursorPosition;
                                            textArea.insert(PPos, PText);
                                            textArea.cursorPosition = PPos + PText.length - 1;
                                            break;

                                        default:
                                            root.dPressed = false;
                                            root.gPressed = false;
                                            
                                            if (event.key === Qt.Key_Escape) {
                                                root.exit();
                                            }
                                            break;
                                    }
                                    return;
                                }
                            } else {
                                if (event.key === Qt.Key_Escape) {
                                    root.exit();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }
            }

            // Footer / Status Bar
            Rectangle {
                id: statusBar
                Layout.fillWidth: true
                Layout.preferredHeight: 25
                color: root.vimEnabled ? (root.vimMode === 'NORMAL' ? Colors.primary : ((root.vimMode === 'VISUAL' || root.vimMode === 'VISUAL_LINE') ? Colors.tertiary : Colors.surface)) : Colors.surface
                radius: Styles.radiusSm

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Styles.marginMd
                    anchors.rightMargin: Styles.marginMd

                    TextStyled {
                        text: root.vimEnabled ? ("VIM: " + root.vimMode + " | i: insert | v/V: visual | Ctrl+Tab: cycle") : "Ctrl+Tab to cycle | Ctrl+1-4 to switch"
                        font.pointSize: Styles.textSm
                        color: root.vimEnabled && (root.vimMode === 'NORMAL' || root.vimMode === 'VISUAL' || root.vimMode === 'VISUAL_LINE') ? Colors.onPrimary : Colors.outline
                        Layout.fillWidth: true
                    }

                    TextStyled {
                        text: "Characters: " + textArea.text.length
                        font.pointSize: Styles.textSm
                        color: root.vimEnabled && (root.vimMode === 'NORMAL' || root.vimMode === 'VISUAL' || root.vimMode === 'VISUAL_LINE') ? Colors.onPrimary : Colors.outline
                    }
                }
            }
        }
    }
}
