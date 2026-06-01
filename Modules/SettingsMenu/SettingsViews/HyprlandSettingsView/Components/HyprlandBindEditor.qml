pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Components
import qs.Settings
import ".." as HyprlandSettingsViews

Rectangle {
    id: root

    required property HyprlandSettingsViews.HyprlandSettingsView view

    visible: false
    Layout.fillHeight: true
    Layout.preferredWidth: 550
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
                onClicked: root.visible = false
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
