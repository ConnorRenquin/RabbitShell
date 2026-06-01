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
    readonly property list<var> editorFields: {
        let fields = [];
        let rows = view.selectedListEditorConfig ? view.selectedListEditorConfig.rows : [];
        for (let i = 0; i < rows.length; i++) {
            fields = fields.concat(rows[i].fields || []);
        }
        return fields;
    }

    visible: false
    Layout.fillHeight: true
    Layout.preferredWidth: 550
    color: Qt.lighter(Colors.surface, 1.2)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginMd
        spacing: Styles.marginSm

        RowLayout {
            Layout.fillWidth: true

            TextStyled {
                Layout.fillWidth: true
                text: "Edit Window Rule"
                font.pointSize: Styles.textLg
            }

            ButtonStyled {
                text: Icons.close
                onClicked: root.visible = false
            }
        }

        ButtonStyled {
            Layout.fillWidth: true
            visible: root.view.selectedListEditorConfig && root.view.selectedListEditorConfig.kind === "windowRuleList" && !root.view.selectedListAdvanced()
            text: "Pick active window"
            onClicked: root.view.pickWindowForRule(root.view.selectedListEditorIndex)
        }

        ScrollView {
            id: fieldScroll
            visible: !root.view.selectedListAdvanced()
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayoutPlus {
                width: fieldScroll.availableWidth
                spacing: Styles.marginXS

                model: root.editorFields
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

                    Rectangle {
                        visible: editorField.isTextField
                        Layout.fillWidth: true
                        color: Qt.darker(Colors.background, Colors.darker)
                        radius: Styles.radiusSm
                        Layout.preferredHeight: visible ? 36 : 0

                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
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

        Rectangle {
            visible: root.view.selectedListAdvanced()
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.darker(Colors.background, Colors.darker)
            radius: Styles.radiusSm

            TextAreaPlus {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                text: root.view.selectedListValue("rawLine")
                placeholderText: root.view.selectedListEditorConfig && root.view.selectedListEditorConfig.kind === "windowRuleList" ? "hl.window_rule({ ... })" : root.view.selectedListEditorConfig && root.view.selectedListEditorConfig.kind === "layerRuleList" ? "hl.layer_rule({ ... })" : "hl.animation({ ... })"
                selectByMouse: true
                onTextChanged: {
                    if (root.view.selectedListEditorIndex >= 0 && text !== root.view.selectedListValue("rawLine"))
                        root.view.updateEditorItem(root.view.selectedListEditorConfig, root.view.selectedListEditorIndex, "rawLine", text);
                }
            }
        }

        SwitchStyled {
            text: "Show Advanced"
            checked: root.view.selectedListAdvanced()
            onToggled: root.view.updateEditorItem(root.view.selectedListEditorConfig, root.view.selectedListEditorIndex, "advanced", checked)
        }
        ButtonStyled {
            text: Icons.trash
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            onClicked: root.view.removeEditorItem(root.view.selectedListEditorConfig, root.view.selectedListEditorIndex)
        }
    }
}
