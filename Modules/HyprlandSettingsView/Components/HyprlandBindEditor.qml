pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Components
import qs.Components.Plus
import qs.Components.Styled
import qs.Settings

Rectangle {
    id: root

    required property var view
    property var editorWindow: null

    property bool showKeyboardCapture: false

    function closeEditor() {
        if (root.editorWindow)
            root.editorWindow.exit();
        else
            root.visible = false;
    }

    function bindModifierLabel(modifier) {
        if (modifier === "super")
            return "SUPER";
        if (modifier === "ctrl")
            return "CTRL";
        if (modifier === "alt")
            return "ALT";
        return "";
    }

    function textBindKey(text) {
        const shifted = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+{}|:\"<>?";
        const needsShift = text.length === 1 && shifted.indexOf(text) >= 0;
        const key = text.length === 1 ? text.toLowerCase() : text;

        if (key === " ")
            return { name: "Space", shift: false };
        if (key === "-")
            return { name: "Minus", shift: false };
        if (key === "_")
            return { name: "Minus", shift: true };
        if (key === "=")
            return { name: "Equal", shift: false };
        if (key === "+")
            return { name: "Equal", shift: true };
        if (key === "[")
            return { name: "BracketLeft", shift: false };
        if (key === "{")
            return { name: "BracketLeft", shift: true };
        if (key === "]")
            return { name: "BracketRight", shift: false };
        if (key === "}")
            return { name: "BracketRight", shift: true };
        if (key === "\\")
            return { name: "Backslash", shift: false };
        if (key === "|")
            return { name: "Backslash", shift: true };
        if (key === ";")
            return { name: "Semicolon", shift: false };
        if (key === ":")
            return { name: "Semicolon", shift: true };
        if (key === "'")
            return { name: "Apostrophe", shift: false };
        if (key === "\"")
            return { name: "Apostrophe", shift: true };
        if (key === ",")
            return { name: "Comma", shift: false };
        if (key === "<")
            return { name: "Comma", shift: true };
        if (key === ".")
            return { name: "Period", shift: false };
        if (key === ">")
            return { name: "Period", shift: true };
        if (key === "/")
            return { name: "Slash", shift: false };
        if (key === "?")
            return { name: "Slash", shift: true };
        if (key === "!")
            return { name: "1", shift: true };
        if (key === "@")
            return { name: "2", shift: true };
        if (key === "#")
            return { name: "3", shift: true };
        if (key === "$")
            return { name: "4", shift: true };
        if (key === "%")
            return { name: "5", shift: true };
        if (key === "^")
            return { name: "6", shift: true };
        if (key === "&")
            return { name: "7", shift: true };
        if (key === "*")
            return { name: "8", shift: true };
        if (key === "(")
            return { name: "9", shift: true };
        if (key === ")")
            return { name: "0", shift: true };
        if (key.length === 1 && key >= "a" && key <= "z")
            return { name: key.toUpperCase(), shift: needsShift };
        if (key.length === 1 && key >= "0" && key <= "9")
            return { name: key, shift: false };

        return { name: "", shift: false };
    }

    function specialBindKey(key) {
        if (key === "escape")
            return "Escape";
        if (key === "backspace")
            return "Backspace";
        if (key === "tab")
            return "Tab";
        if (key === "enter")
            return "Return";
        if (key === "left")
            return "Left";
        if (key === "right")
            return "Right";
        if (key === "up")
            return "Up";
        if (key === "down")
            return "Down";
        if (key === "menu")
            return "Menu";
        return "";
    }

    function setKeyboardBind(keyName, modifier, shift) {
        if (root.view.selectedBindIndex < 0 || keyName.length === 0)
            return;

        let parts = [];
        const modifierLabel = root.bindModifierLabel(modifier);
        if (modifierLabel.length > 0)
            parts.push(modifierLabel);
        if (shift)
            parts.push("SHIFT");
        parts.push(keyName);

        root.view.updateBindItem(root.view.selectedBindIndex, "keys", parts.join(" + "));
        root.showKeyboardCapture = false;
    }

    function setKeyboardTextBind(text, modifier) {
        const key = root.textBindKey(text);
        root.setKeyboardBind(key.name, modifier, key.shift);
    }

    function setKeyboardSpecialBind(key, modifier) {
        root.setKeyboardBind(root.specialBindKey(key), modifier, false);
    }

    visible: false
    Layout.fillHeight: true
    Layout.preferredWidth: 950
    color: Qt.lighter(Colors.surface, 1.2)

    component InputFrameLocal: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        color: Qt.darker(Colors.background, Colors.darker)
        radius: Styles.radiusSm
    }

    component InputTextFieldLocal: TextFieldStyled {
        anchors.fill: parent
        anchors.leftMargin: Styles.marginSm
        anchors.rightMargin: Styles.marginSm
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginMd
        spacing: Styles.marginSm

        RowLayout {
            Layout.fillWidth: true

            TextStyled {
                Layout.fillWidth: true
                text: "Edit keybind"
                font.pointSize: Styles.textLg
            }

            ButtonStyled {
                text: Icons.close
                onClicked: root.closeEditor()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            TextStyled {
                text: "Shortcut Name"
            }
            InputFrameLocal {
                Layout.preferredHeight: 36
                InputTextFieldLocal {
                    text: root.view.bindValue(root.view.selectedBindIndex, "description")
                    placeholderText: "Launch terminal"
                    onTextEdited: root.view.updateBindItem(root.view.selectedBindIndex, "description", text)
                }
            }

            TextStyled {
                text: "Keybind"
            }
            RowLayout {
                Layout.fillWidth: true
                InputFrameLocal {
                    Layout.preferredHeight: 36
                    InputTextFieldLocal {
                        text: root.view.bindValue(root.view.selectedBindIndex, "keys")
                        placeholderText: "Super + Return"
                        onTextEdited: root.view.updateBindItem(root.view.selectedBindIndex, "keys", text)
                    }
                }
                ButtonStyled {
                    text: root.view.capturingBindIndex === root.view.selectedBindIndex ? "Press keys..." : "Detect"
                    defaultColor: root.view.capturingBindIndex === root.view.selectedBindIndex ? Colors.primary : Colors.background
                    onClicked: root.view.startCapturingBind(root.view.selectedBindIndex)
                }
                ButtonStyled {
                    text: root.showKeyboardCapture ? "Hide Keyboard" : "Keyboard"
                    defaultColor: root.showKeyboardCapture ? Colors.primary : Colors.background
                    textColor: root.showKeyboardCapture ? Colors.onPrimary : Colors.onSurface
                    onClicked: root.showKeyboardCapture = !root.showKeyboardCapture
                }
            }

            Rectangle {
                visible: root.showKeyboardCapture
                Layout.fillWidth: true
                Layout.preferredHeight: 230
                color: Colors.surface
                radius: Styles.radiusLg
                clip: true

                Keyboard {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    onInputText: (text, modifier) => root.setKeyboardTextBind(text, modifier)
                    onSpecialKey: (key, modifier) => root.setKeyboardSpecialBind(key, modifier)
                }
            }

            TextStyled {
                text: "Dispatcher"
            }
            ComboBoxStyled {
                visible: !(root.view.selectedBindIndex >= 0 && !!root.view.bindItems[root.view.selectedBindIndex] && !!root.view.bindItems[root.view.selectedBindIndex].advanced)
                Layout.fillWidth: true
                model: root.view.commonBindActions.map(action => action.label)
                currentIndex: root.view.bindActionIndex(root.view.bindItems[root.view.selectedBindIndex])
                onActivated: index => root.view.setBindAction(root.view.selectedBindIndex, root.view.commonBindActions[index].id)
            }

            TextStyled {
                visible: !(root.view.selectedBindIndex >= 0 && !!root.view.bindItems[root.view.selectedBindIndex] && !!root.view.bindItems[root.view.selectedBindIndex].advanced) && !!root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).param
                text: root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).param || "Value"
            }
            RowLayout {
                visible: !(root.view.selectedBindIndex >= 0 && !!root.view.bindItems[root.view.selectedBindIndex] && !!root.view.bindItems[root.view.selectedBindIndex].advanced) && !!root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).param
                Layout.fillWidth: true
                spacing: Styles.marginSm

                InputFrameLocal {
                    visible: !(root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).options)
                    Layout.preferredHeight: 36
                    InputTextFieldLocal {
                        text: root.view.bindParam(root.view.bindItems[root.view.selectedBindIndex], root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).param || "")
                        placeholderText: root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).placeholder || ""
                        onTextEdited: root.view.setBindParam(root.view.selectedBindIndex, root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).param, text)
                    }
                }

                ComboBoxStyled {
                    visible: !!root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).options
                    Layout.fillWidth: true
                    model: root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).options || []
                    currentIndex: model.indexOf(root.view.bindParam(root.view.bindItems[root.view.selectedBindIndex], root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).param || ""))
                    onActivated: index => root.view.setBindParam(root.view.selectedBindIndex, root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).param, model[index])
                }

                InputFrameLocal {
                    visible: !!root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).secondaryParam
                    Layout.preferredHeight: 36
                    InputTextFieldLocal {
                        text: root.view.bindParam(root.view.bindItems[root.view.selectedBindIndex], root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).secondaryParam || "")
                        placeholderText: root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).secondaryPlaceholder || ""
                        onTextEdited: root.view.setBindParam(root.view.selectedBindIndex, root.view.bindAction(root.view.bindItems[root.view.selectedBindIndex]).secondaryParam, text)
                    }
                }
            }

            ComboBoxStyled {
                visible: root.view.selectedBindIndex >= 0 && !!root.view.bindItems[root.view.selectedBindIndex] && !!root.view.bindItems[root.view.selectedBindIndex].advanced
                Layout.fillWidth: true
                model: ["exec_cmd", "global", "raw", "callback"]
                currentIndex: model.indexOf(root.view.bindValue(root.view.selectedBindIndex, "dispatcher"))
                onActivated: index => root.view.updateBindItem(root.view.selectedBindIndex, "dispatcher", model[index])
            }

            TextStyled {
                visible: root.view.selectedBindIndex >= 0 && !!root.view.bindItems[root.view.selectedBindIndex] && !!root.view.bindItems[root.view.selectedBindIndex].advanced
                text: "Argument"
            }
            Rectangle {
                visible: root.view.selectedBindIndex >= 0 && !!root.view.bindItems[root.view.selectedBindIndex] && !!root.view.bindItems[root.view.selectedBindIndex].advanced
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: Qt.darker(Colors.background, Colors.darker)
                radius: Styles.radiusSm

                TextArea {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    text: root.view.bindValue(root.view.selectedBindIndex, "argument")
                    placeholderText: "kitty, quickshell:powermenu, hl.dsp.focus(...), or function() ... end"
                    color: Colors.onBackground
                    selectedTextColor: Colors.background
                    selectionColor: Colors.primary
                    font.family: Styles.defaultFontFamily
                    font.pointSize: Styles.textSm
                    wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                    selectByMouse: true
                    onTextChanged: {
                        if (root.view.selectedBindIndex >= 0 && text !== root.view.bindValue(root.view.selectedBindIndex, "argument"))
                            root.view.updateBindItem(root.view.selectedBindIndex, "argument", text);
                    }
                }
            }
        }

        TextStyled {
            text: "Flags"
        }
        GridLayoutPlus {
            Layout.fillWidth: true
            columns: 2
            model: root.view.bindFlagOptions
            delegate: SwitchStyled {
                required property string modelData
                text: modelData
                checked: root.view.bindHasFlag(root.view.bindItems[root.view.selectedBindIndex], modelData)
                onToggled: root.view.setBindFlag(root.view.selectedBindIndex, modelData, checked)
            }
        }
        Item {
            Layout.fillHeight: true
        }

        SwitchStyled {
            checked: root.view.selectedBindIndex >= 0 && !!root.view.bindItems[root.view.selectedBindIndex] && !!root.view.bindItems[root.view.selectedBindIndex].advanced
            text: "Show Advanced"
            onToggled: root.view.setBindAdvanced(root.view.selectedBindIndex, checked)
        }

        ButtonStyled {
            text: Icons.trash
            Layout.fillWidth: true
            onClicked: root.view.removeBindItem(root.view.selectedBindIndex)
        }
    }
}
