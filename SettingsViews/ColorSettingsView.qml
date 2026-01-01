pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Constants
import qs.Components

ListView {
    anchors.fill: parent
    anchors.margins: Styles.marginSm

    spacing: Styles.marginSm
    clip: true
    model: Object.keys(Colors.userColors)

    ScrollBar.vertical: ScrollBar {
        active: true
        policy: ScrollBar.AsNeeded
    }

    delegate: Rectangle {
        id: colorEntry

        color: Colors.background
        implicitWidth: parent.width
        implicitHeight: 100
        radius: Styles.radiusSm

        required property string modelData
        required property int index

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Styles.marginSm

            TextStyled {
                text: colorEntry.modelData
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Color preview rectangle
                Rectangle {
                    id: colorPreview
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    color: Colors.userColors[colorEntry.modelData] || "#000000"
                    border.width: 1
                    border.color: Colors.foreground
                    radius: Styles.radiusSm
                }

                // Color text field
                TextFieldStyled {
                    id: textField
                    Layout.fillWidth: true

                    Component.onCompleted: {
                        text = Colors.userColors[colorEntry.modelData] || "";
                    }

                    Connections {
                        target: Colors
                        function onUserColorsChanged() {
                            textField.text = Colors.userColors[colorEntry.modelData] || "";
                        }
                    }

                    onTextChanged: {
                        // Update the preview color as the text changes
                        if (isValidColor(text)) {
                            colorPreview.color = text;
                        }
                    }

                    onEditingFinished: {
                        if (isValidColor(text)) {
                            var newColors = Object.assign({}, Colors.userColors);
                            newColors[colorEntry.modelData] = text;
                            Colors.userColors = newColors;
                        }
                    }

                    function isValidColor(color) {
                        // Simple validation for hex colors
                        return color.match(/^#[0-9A-Fa-f]{6}$/) !== null;
                    }
                }

                // Color picker button
                ButtonStyled {
                    text: "..."
                    onClicked: colorDialog.open()

                    Popup {
                        id: colorDialog
                        width: 300
                        height: 300
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                        anchors.centerIn: Overlay.overlay

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Styles.marginSm

                            // Simple color grid
                            GridView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                cellWidth: 50
                                cellHeight: 50

                                model: ["#000000", "#FFFFFF", "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF", "#800000", "#008000", "#000080", "#808000", "#800080", "#008080", "#808080", "#C0C0C0", "#FF8080", "#80FF80", "#8080FF", "#FFFF80", "#FF80FF", "#80FFFF", "#333333", "#666666", "#999999"]

                                delegate: Item {
                                    id: colorSwatch
                                    width: 45
                                    height: 45

                                    required property string modelData

                                    Rectangle {
                                        anchors.fill: parent
                                        color: colorSwatch.modelData
                                        border.width: 1
                                        border.color: Colors.foreground

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                var selectedColor = colorSwatch.modelData;
                                                textField.text = selectedColor;
                                                var newColors = Object.assign({}, Colors.userColors);
                                                newColors[colorEntry.modelData] = selectedColor;
                                                Colors.userColors = newColors;
                                                colorDialog.close();
                                            }
                                        }
                                    }
                                }
                            }

                            // Close button
                            ButtonStyled {
                                Layout.alignment: Qt.AlignRight
                                text: "Close"
                                onClicked: colorDialog.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
