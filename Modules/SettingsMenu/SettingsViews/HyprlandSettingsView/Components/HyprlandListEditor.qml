pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Components
import qs.Settings

Rectangle {
    id: root

    required property var view

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
                text: root.view.selectedListEditorConfig ? "Edit " + root.view.editorTitle(root.view.selectedListEditorConfig, root.view.selectedListItem()) : "Edit rule"
                font.pointSize: Styles.textLg
            }

            ButtonStyled {
                text: Icons.close
                onClicked: root.visible = false
            }
        }

        SwitchStyled {
            text: "Show raw rule"
            checked: root.view.selectedListAdvanced()
            onToggled: root.view.updateEditorItem(root.view.selectedListEditorConfig, root.view.selectedListEditorIndex, "advanced", checked)
        }

        ButtonStyled {
            visible: root.view.selectedListEditorConfig && root.view.selectedListEditorConfig.kind === "windowRuleList" && !root.view.selectedListAdvanced()
            text: "Pick active window"
            onClicked: root.view.pickWindowForRule(root.view.selectedListEditorIndex)
        }


        ScrollView {
            visible: !root.view.selectedListAdvanced()
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayoutPlus {
                width: parent.width
                spacing: Styles.marginSm

                model: root.view.selectedListEditorConfig ? root.view.selectedListEditorConfig.rows : []
                delegate: ColumnLayout {
                    id: editorRow
                    required property var modelData

                    width: parent.width
                    spacing: Styles.marginXS

                    Repeater {
                        model: editorRow.modelData.fields || []

                        delegate: ColumnLayout {
                            id: editorField
                            required property var modelData
                            readonly property bool isBoolField: modelData.type === "bool"
                            readonly property bool isTextField: modelData.type === "text"

                            Layout.fillWidth: true
                            spacing: Styles.marginXS

                            TextStyled {
                                visible: !editorField.isBoolField
                                text: editorField.modelData.label
                            }

                            InputFrameLocal {
                                visible: editorField.isTextField
                                Layout.preferredHeight: 36

                                InputTextFieldLocal {
                                    text: root.view.fieldText(root.view.selectedListItem(), editorField.modelData)
                                    placeholderText: editorField.modelData.placeholder || ""
                                    inputMethodHints: editorField.modelData.numeric ? Qt.ImhFormattedNumbersOnly : Qt.ImhNone
                                    onTextEdited: root.view.updateEditorItem(root.view.selectedListEditorConfig, root.view.selectedListEditorIndex, editorField.modelData.key, text)
                                }
                            }

                            SwitchStyled {
                                visible: editorField.isBoolField
                                text: editorField.modelData.label
                                checked: root.view.boolFieldValue(root.view.selectedListItem(), editorField.modelData)
                                onToggled: root.view.updateEditorItem(root.view.selectedListEditorConfig, root.view.selectedListEditorIndex, editorField.modelData.key, checked)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: root.view.selectedListAdvanced()
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.darker(Colors.background, Colors.darker)
            radius: Styles.radiusSm

            TextArea {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                text: root.view.selectedListValue("rawLine")
                placeholderText: root.view.selectedListEditorConfig && root.view.selectedListEditorConfig.kind === "windowRuleList" ? "hl.window_rule({ ... })" : root.view.selectedListEditorConfig && root.view.selectedListEditorConfig.kind === "layerRuleList" ? "hl.layer_rule({ ... })" : "hl.animation({ ... })"
                color: Colors.onBackground
                selectedTextColor: Colors.background
                selectionColor: Colors.primary
                font.family: Styles.defaultFontFamily
                font.pointSize: Styles.textSm
                wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                selectByMouse: true
                onTextChanged: {
                    if (root.view.selectedListEditorIndex >= 0 && text !== root.view.selectedListValue("rawLine"))
                        root.view.updateEditorItem(root.view.selectedListEditorConfig, root.view.selectedListEditorIndex, "rawLine", text);
                }
            }
        }

    }
}
