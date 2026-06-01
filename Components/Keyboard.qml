pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components

Rectangle {
    id: root

    color: Colors.surface
    radius: Styles.radiusLg
    implicitWidth: 1040
    implicitHeight: keyboardColumn.implicitHeight + Styles.marginMd

    property int keyWidth: 56
    property int keyHeight: 48
    property bool shiftActive: false
    property bool capsActive: false
    property string activeModifier: ""

    readonly property var topRow: [
        {
            label: "Esc",
            key: "escape",
            width: 1.4
        },
        {
            normal: "1",
            shifted: "!"
        },
        {
            normal: "2",
            shifted: "@"
        },
        {
            normal: "3",
            shifted: "#"
        },
        {
            normal: "4",
            shifted: "$"
        },
        {
            normal: "5",
            shifted: "%"
        },
        {
            normal: "6",
            shifted: "^"
        },
        {
            normal: "7",
            shifted: "&"
        },
        {
            normal: "8",
            shifted: "*"
        },
        {
            normal: "9",
            shifted: "("
        },
        {
            normal: "0",
            shifted: ")"
        },
        {
            normal: "-",
            shifted: "_"
        },
        {
            normal: "=",
            shifted: "+"
        },
        {
            label: "⌫",
            key: "backspace",
            width: 2.1
        }
    ]
    readonly property var qwertyRow: [
        {
            label: "Tab",
            key: "tab",
            width: 1.7
        },
        {
            normal: "q",
            letter: true
        },
        {
            normal: "w",
            letter: true
        },
        {
            normal: "e",
            letter: true
        },
        {
            normal: "r",
            letter: true
        },
        {
            normal: "t",
            letter: true
        },
        {
            normal: "y",
            letter: true
        },
        {
            normal: "u",
            letter: true
        },
        {
            normal: "i",
            letter: true
        },
        {
            normal: "o",
            letter: true
        },
        {
            normal: "p",
            letter: true
        },
        {
            normal: "[",
            shifted: "{"
        },
        {
            normal: "]",
            shifted: "}"
        },
        {
            normal: "\\",
            shifted: "|",
            width: 1.4
        }
    ]
    readonly property var homeRow: [
        {
            label: capsActive ? "Caps ●" : "Caps",
            key: "caps",
            width: 2.0
        },
        {
            normal: "a",
            letter: true
        },
        {
            normal: "s",
            letter: true
        },
        {
            normal: "d",
            letter: true
        },
        {
            normal: "f",
            letter: true
        },
        {
            normal: "g",
            letter: true
        },
        {
            normal: "h",
            letter: true
        },
        {
            normal: "j",
            letter: true
        },
        {
            normal: "k",
            letter: true
        },
        {
            normal: "l",
            letter: true
        },
        {
            normal: ";",
            shifted: ":"
        },
        {
            normal: "'",
            shifted: "\""
        },
        {
            label: "Enter",
            key: "enter",
            width: 2.2
        }
    ]
    readonly property var bottomRow: [
        {
            label: shiftActive ? "Shift ●" : "Shift",
            key: "shift",
            width: 2.5
        },
        {
            normal: "z",
            letter: true
        },
        {
            normal: "x",
            letter: true
        },
        {
            normal: "c",
            letter: true
        },
        {
            normal: "v",
            letter: true
        },
        {
            normal: "b",
            letter: true
        },
        {
            normal: "n",
            letter: true
        },
        {
            normal: "m",
            letter: true
        },
        {
            normal: ",",
            shifted: "<"
        },
        {
            normal: ".",
            shifted: ">"
        },
        {
            normal: "/",
            shifted: "?"
        },
        {
            label: "Shift",
            key: "shift",
            width: 2.5
        }
    ]
    readonly property var controlRow: [
        {
            label: activeModifier === "ctrl" ? "Ctrl ●" : "Ctrl",
            key: "ctrl",
            width: 1.5
        },
        {
            label: activeModifier === "super" ? "Super ●" : "Super",
            key: "super",
            width: 1.5
        },
        {
            label: activeModifier === "alt" ? "Alt ●" : "Alt",
            key: "alt",
            width: 1.5
        },
        {
            label: "Space",
            normal: " ",
            width: 6.8
        },
        {
            label: activeModifier === "alt" ? "Alt ●" : "Alt",
            key: "alt",
            width: 1.5
        },
        {
            label: "Fn",
            key: "fn",
            width: 1.2
        },
        {
            label: "Menu",
            key: "menu",
            width: 1.4
        },
        {
            label: "←",
            key: "left",
            width: 1.2
        },
        {
            label: "↓",
            key: "down",
            width: 1.2
        },
        {
            label: "↑",
            key: "up",
            width: 1.2
        },
        {
            label: "→",
            key: "right",
            width: 1.2
        }
    ]

    signal inputText(string text, string modifier)
    signal specialKey(string key, string modifier)
    signal closedRequested

    function displayLabel(keyData) {
        if (keyData.label !== undefined)
            return keyData.label;
        if (keyData.letter)
            return (root.shiftActive || root.capsActive) ? keyData.normal.toUpperCase() : keyData.normal;
        return root.shiftActive && keyData.shifted !== undefined ? keyData.shifted : keyData.normal;
    }

    function outputText(keyData) {
        if (keyData.letter)
            return (root.shiftActive !== root.capsActive) ? keyData.normal.toUpperCase() : keyData.normal;
        return root.shiftActive && keyData.shifted !== undefined ? keyData.shifted : keyData.normal;
    }

    function consumeShift() {
        if (root.shiftActive)
            root.shiftActive = false;
    }

    function handleKey(keyData) {
        const display = root.displayLabel(keyData);
        const beforeState = {
            display,
            key: keyData.key ?? "",
            normal: keyData.normal ?? "",
            shiftActive: root.shiftActive,
            capsActive: root.capsActive,
            activeModifier: root.activeModifier
        };
        console.log("Keyboard: pressed", JSON.stringify(beforeState));

        if (keyData.key === "shift") {
            root.shiftActive = !root.shiftActive;
            console.log("Keyboard: toggled shift", root.shiftActive);
            return;
        }
        if (keyData.key === "caps") {
            root.capsActive = !root.capsActive;
            console.log("Keyboard: toggled caps", root.capsActive);
            return;
        }
        if (keyData.key === "ctrl" || keyData.key === "alt" || keyData.key === "super") {
            root.activeModifier = root.activeModifier === keyData.key ? "" : keyData.key;
            console.log("Keyboard: toggled modifier", JSON.stringify({
                modifier: keyData.key,
                activeModifier: root.activeModifier
            }));
            return;
        }
        if (keyData.normal !== undefined) {
            const text = root.outputText(keyData);
            console.log("Keyboard: emit inputText", JSON.stringify({
                text,
                modifier: root.activeModifier
            }));
            root.inputText(text, root.activeModifier);
            root.activeModifier = "";
            root.consumeShift();
            return;
        }
        console.log("Keyboard: emit specialKey", JSON.stringify({
            key: keyData.key,
            modifier: root.activeModifier
        }));
        root.specialKey(keyData.key, root.activeModifier);
        root.activeModifier = "";
        root.consumeShift();
    }

    ColumnLayout {
        id: keyboardColumn
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        KeyboardRow {
            keyModel: root.topRow
        }
        KeyboardRow {
            keyModel: root.qwertyRow
        }
        KeyboardRow {
            keyModel: root.homeRow
        }
        KeyboardRow {
            keyModel: root.bottomRow
        }
        KeyboardRow {
            keyModel: root.controlRow
        }
    }

    component KeyboardRow: Item {
        id: keyboardRow

        required property var keyModel

        readonly property int keyCount: keyModel.length
        readonly property real rowSpacing: Styles.marginSm
        readonly property real totalWeight: {
            var total = 0;
            for (var i = 0; i < keyModel.length; i++)
                total += keyModel[i].width === undefined ? 1 : keyModel[i].width;
            return total;
        }
        readonly property real availableKeyWidth: Math.max(0, width - rowSpacing * Math.max(0, keyCount - 1))

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 32
        Layout.preferredHeight: root.keyHeight
        implicitHeight: root.keyHeight

        function keyWeight(index) {
            const keyData = keyModel[index];
            return keyData.width === undefined ? 1 : keyData.width;
        }

        function keyX(index) {
            var total = 0;
            for (var i = 0; i < index; i++)
                total += keyWeight(i);
            return availableKeyWidth * total / totalWeight + rowSpacing * index;
        }

        function keyWidth(index) {
            return availableKeyWidth * keyWeight(index) / totalWeight;
        }

        Repeater {
            model: keyboardRow.keyModel

            delegate: ButtonStyled {
                required property var modelData
                required property int index

                x: keyboardRow.keyX(index)
                y: 0
                width: keyboardRow.keyWidth(index)
                height: keyboardRow.height
                text: root.displayLabel(modelData)
                defaultColor: (modelData.key === "shift" && root.shiftActive) || (modelData.key === "caps" && root.capsActive) || (modelData.key !== undefined && modelData.key === root.activeModifier) ? Colors.primary : Colors.surfaceVariant
                textColor: defaultColor === Colors.primary ? Colors.onPrimary : Colors.onSurface
                pointSize: Styles.textMd
                onClicked: root.handleKey(modelData)
            }
        }
    }
}
