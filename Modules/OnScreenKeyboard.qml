import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components

Item {
    id: root

    property bool oskVisible: false
    property string shortcutName: "keyboard"
    property var ydotoolQueue: []

    function runYdotool(command) {
        const nextQueue = root.ydotoolQueue.slice();
        nextQueue.push(command);
        root.ydotoolQueue = nextQueue;
        root.drainYdotoolQueue();
    }

    function drainYdotoolQueue() {
        if (ydotoolRunner.running || root.ydotoolQueue.length === 0)
            return;

        const command = root.ydotoolQueue[0];
        root.ydotoolQueue = root.ydotoolQueue.slice(1);
        ydotoolRunner.command = command;
        ydotoolRunner.running = true;
    }

    function modifierToKeycode(modifier) {
        if (modifier === "ctrl")
            return 29;
        if (modifier === "alt")
            return 56;
        if (modifier === "super")
            return 125;
        return 0;
    }

    function textToKeycode(text) {
        const key = text.length === 1 ? text.toLowerCase() : text;
        if (key === "1" || key === "!")
            return 2;
        if (key === "2" || key === "@")
            return 3;
        if (key === "3" || key === "#")
            return 4;
        if (key === "4" || key === "$")
            return 5;
        if (key === "5" || key === "%")
            return 6;
        if (key === "6" || key === "^")
            return 7;
        if (key === "7" || key === "&")
            return 8;
        if (key === "8" || key === "*")
            return 9;
        if (key === "9" || key === "(")
            return 10;
        if (key === "0" || key === ")")
            return 11;
        if (key === "-" || key === "_")
            return 12;
        if (key === "=" || key === "+")
            return 13;
        if (key === "q")
            return 16;
        if (key === "w")
            return 17;
        if (key === "e")
            return 18;
        if (key === "r")
            return 19;
        if (key === "t")
            return 20;
        if (key === "y")
            return 21;
        if (key === "u")
            return 22;
        if (key === "i")
            return 23;
        if (key === "o")
            return 24;
        if (key === "p")
            return 25;
        if (key === "[" || key === "{")
            return 26;
        if (key === "]" || key === "}")
            return 27;
        if (key === "\\" || key === "|")
            return 43;
        if (key === "a")
            return 30;
        if (key === "s")
            return 31;
        if (key === "d")
            return 32;
        if (key === "f")
            return 33;
        if (key === "g")
            return 34;
        if (key === "h")
            return 35;
        if (key === "j")
            return 36;
        if (key === "k")
            return 37;
        if (key === "l")
            return 38;
        if (key === ";" || key === ":")
            return 39;
        if (key === "'" || key === "\"")
            return 40;
        if (key === "z")
            return 44;
        if (key === "x")
            return 45;
        if (key === "c")
            return 46;
        if (key === "v")
            return 47;
        if (key === "b")
            return 48;
        if (key === "n")
            return 49;
        if (key === "m")
            return 50;
        if (key === "," || key === "<")
            return 51;
        if (key === "." || key === ">")
            return 52;
        if (key === "/" || key === "?")
            return 53;
        if (key === " ")
            return 57;
        return 0;
    }

    function sendYdotoolKey(keycode, source) {
        if (keycode === 0) {
            console.log("OnScreenKeyboard: missing ydotool keycode", JSON.stringify({
                keycode,
                source
            }));
            return false;
        }

        const command = ["ydotool", "key", "--key-delay", "0", keycode + ":1", keycode + ":0"];
        console.log("OnScreenKeyboard: sendYdotoolKey", JSON.stringify({
            keycode,
            command,
            source
        }));
        root.runYdotool(command);
        return true;
    }

    function textNeedsShift(text) {
        return text.length === 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+{}|:\"<>?".indexOf(text) >= 0;
    }

    function sendYdotoolCombo(keycode, modifier, source, includeShift) {
        const modifierKeycode = root.modifierToKeycode(modifier);
        const shiftKeycode = 42;
        if (keycode === 0 || modifierKeycode === 0) {
            console.log("OnScreenKeyboard: missing ydotool combo keycode", JSON.stringify({
                keycode,
                modifier,
                modifierKeycode,
                source,
                includeShift
            }));
            return false;
        }

        const command = ["ydotool", "key", "--key-delay", "0", modifierKeycode + ":1"];
        if (includeShift)
            command.push(shiftKeycode + ":1");
        command.push(keycode + ":1", keycode + ":0");
        if (includeShift)
            command.push(shiftKeycode + ":0");
        command.push(modifierKeycode + ":0");
        console.log("OnScreenKeyboard: sendYdotoolCombo", JSON.stringify({
            keycode,
            modifier,
            modifierKeycode,
            includeShift,
            command,
            source
        }));
        root.runYdotool(command);
        return true;
    }

    function sendText(text, modifier) {
        if (text.length === 0) {
            console.log("OnScreenKeyboard: ignored empty text input");
            return;
        }

        const keycode = root.textToKeycode(text);
        if (modifier !== "" && root.sendYdotoolCombo(keycode, modifier, {
            type: "text",
            text
        }, root.textNeedsShift(text)))
            return;

        const command = ["ydotool", "type", "--key-delay", "0", text];
        console.log("OnScreenKeyboard: sendText", JSON.stringify({
            text,
            modifier,
            keycode,
            command,
            mode: "ydotool-type"
        }));
        root.runYdotool(command);
    }

    function specialToKeycode(key) {
        if (key === "escape")
            return 1;
        if (key === "backspace")
            return 14;
        if (key === "tab")
            return 15;
        if (key === "enter")
            return 28;
        if (key === "left")
            return 105;
        if (key === "down")
            return 108;
        if (key === "up")
            return 103;
        if (key === "right")
            return 106;
        if (key === "menu")
            return 127;
        return 0;
    }

    function sendSpecial(key, modifier) {
        if (key === "fn") {
            console.log("OnScreenKeyboard: ignored fn key");
            return;
        }

        const keycode = root.specialToKeycode(key);

        if (modifier !== "" && root.sendYdotoolCombo(keycode, modifier, {
            type: "special",
            key
        }, false))
            return;

        root.sendYdotoolKey(keycode, {
            type: "special",
            key
        });
    }

    Process {
        id: ydotoolDaemonCheck
        command: ["pgrep", "-x", "ydotoold"]
        running: true

        function onExited(exitCode) {
            if (exitCode !== 0)
                console.log("OnScreenKeyboard: ydotoold does not appear to be running. ydotool key injection will not work until ydotoold is started and accessible.");
            else
                console.log("OnScreenKeyboard: ydotoold is running");
        }
    }

    Process {
        id: ydotoolRunner
        running: false

        function onExited(exitCode) {
            console.log("OnScreenKeyboard: ydotool exited", JSON.stringify({
                exitCode,
                command: ydotoolRunner.command
            }));
            root.drainYdotoolQueue();
        }

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function (data) {
                if (data.trim() !== "")
                    console.log("OnScreenKeyboard: ydotool stdout:", data.trim());
            }
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: function (data) {
                if (data.trim() !== "")
                    console.log("OnScreenKeyboard: ydotool stderr:", data.trim());
            }
        }
    }

    GlobalShortcut {
        name: root.shortcutName
        onPressed: root.oskVisible = !root.oskVisible
    }

    Loader {
        id: oskLoader
        active: root.oskVisible

        sourceComponent: PanelWindow {
            id: oskWindow

            visible: oskLoader.active
            implicitWidth: 1580
            implicitHeight: 390
            color: "transparent"

            anchors.bottom: true

            WlrLayershell.namespace: "quickshell:osk"
            WlrLayershell.layer: WlrLayer.Overlay

            mask: Region {
                item: base
            }

            Rectangle {
                id: base

                anchors.fill: parent
                anchors.margins: Styles.marginSm
                color: Colors.background
                radius: Styles.radiusLg
                focus: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm

                    RowLayout {
                        id: topBar
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        spacing: Styles.marginSm
                        SliderStyled {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            onValueChanged: oskWindow.implicitWidth = value
                            from: 500
                            to: 2000
                            showPercentage: false
                        }
                        ButtonStyled {
                            text: "×"
                            implicitWidth: 42
                            Layout.fillHeight: true
                            defaultColor: Colors.surfaceVariant
                            textColor: Colors.onSurface
                            onClicked: root.oskVisible = false
                        }
                    }

                    Loader {
                        id: keyboardLoader

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: Qt.resolvedUrl("../Components/Keyboard.qml")
                    }

                    Connections {
                        target: keyboardLoader.item
                        function onInputText(text, modifier) {
                            console.log("OnScreenKeyboard: received inputText", JSON.stringify({
                                text,
                                modifier
                            }));
                            root.sendText(text, modifier);
                        }
                        function onSpecialKey(key, modifier) {
                            console.log("OnScreenKeyboard: received specialKey", JSON.stringify({
                                key,
                                modifier
                            }));
                            root.sendSpecial(key, modifier);
                        }
                        function onClosedRequested() {
                            console.log("OnScreenKeyboard: received closedRequested");
                            root.oskVisible = false;
                        }
                    }
                }
            }
        }
    }
}
