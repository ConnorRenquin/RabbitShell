pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components

ListView {
    id: root

    anchors.fill: parent
    anchors.margins: Styles.marginSm

    spacing: Styles.marginSm
    clip: true
    model: Object.keys(Colors.userColors)

    ScrollBar.vertical: ScrollBar {
        active: true
        policy: ScrollBar.AsNeeded
    }

    function isValidColor(color) {
        return color.match(/^#[0-9A-Fa-f]{6}$/) !== null;
    }

    delegate: Rectangle {
        id: colorEntry

        required property string modelData
        required property int index

        color: Colors.background
        implicitWidth: parent?.width ?? 0
        implicitHeight: 100
        radius: Styles.radiusSm

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Styles.marginSm

            TextStyled {
                id: colorName
                text: colorEntry.modelData
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Rectangle {
                    id: colorPreview
                    Layout.preferredWidth: 40
                    Layout.fillHeight: true
                    color: root.isValidColor(colorTextField?.text) ? colorTextField.text : Colors.userColors[colorEntry.modelData] || "#000000"
                    radius: Styles.radiusSm
                }

                Rectangle {
                    id: validationIndicator
                    Layout.preferredWidth: 10
                    Layout.fillHeight: true
                    radius: Styles.radiusSm
                    color: root.isValidColor(colorTextField.text) ? Colors.success : Colors.error
                }

                TextFieldStyled {
                    id: colorTextField

                    Layout.fillWidth: true
                    Component.onCompleted: text = Colors.userColors[colorEntry.modelData] || ""

                    Connections {
                        target: Colors
                        function onUserColorsChanged() {
                            colorTextField.text = Colors.userColors[colorEntry.modelData] || "";
                        }
                    }
                }

                ButtonStyled {
                    id: applyButton
                    text: "Apply"
                    enabled: root.isValidColor(colorTextField.text)
                    onClicked: {
                        var newColors = Object.assign({}, Colors.userColors);
                        newColors[colorEntry.modelData] = colorTextField.text;
                        Colors.userColors = newColors;
                    }
                }

                ButtonStyled {
                    id: resetButton
                    text: "Reset"
                    onClicked: colorTextField.text = Colors.userColors[colorEntry.modelData]
                }
            }
        }
    }
}
