pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.Components
import qs.Components.Styled
import qs.Settings
import qs.Modules.SettingsMenu.SettingsViews.Components

Rectangle {
    id: root

    required property string name

    anchors.fill: parent
    color: Colors.surface

    property bool showStyles: true

    function isValidColor(color) {
        return color.match(/^#[0-9A-Fa-f]{6}$/) !== null;
    }

    ConfirmationDialog {
        id: deleteDialog
        title: "Delete current theme?"
        warning: "This action can't be undone."
        onAccepted: {
            var themePath = Colors.directory + Settings.get('currentTheme').value;
            Quickshell.execDetached(['bash', '-c', 'rm "$XDG_CONFIG_HOME/quickshell/Settings/' + themePath + '"']);
            if (Colors.availableThemes.length > 1) {
                var newTheme = Colors.availableThemes.find(t => t !== Colors.currentTheme);
                if (newTheme) {
                    Settings.change({name: 'currentTheme', value: newTheme});
                }
            }
            Colors.refreshThemes();
        }
    }
    TextFieldDialog {
        id: renameDialog
        title: "Rename"
        currentText: Colors.currentTheme.replace('.json', '')
        onAccepted: {
            var newName = currentText.trim();
            if (newName && newName !== Colors.currentTheme.replace('.json', '')) {
                if (!newName.endsWith('.json')) {
                    newName += '.json';
                }
                var oldPath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + Colors.currentTheme;
                var newPath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + newName;
                Quickshell.execDetached(['bash', '-c', 'mv "' + oldPath + '" "' + newPath + '"']);
                Settings.change({name: 'currentTheme', value: newName});
                Colors.refreshThemes();
            }
        }
    }
    TextFieldDialog {
        id: createDialog
        title: "Create New Theme"
        placeholderText: "Enter new theme name"
        onAccepted: {
            var newName = currentText.trim();
            if (newName) {
                if (!newName.endsWith('.json')) {
                    newName += '.json';
                }
                copyProcess.destName = newName;
                copyProcess.command = ['bash', '-c', 'cp "$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + Colors.currentTheme + '" "$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + newName + '"'];
                copyProcess.running = true;
                currentText.text = "";
            }
        }
    }
    ColorPickerDialog {
        id: colorPickerDialog
        property var targetTextField: null
        onAccepted: (hexColor) => {
            if (targetTextField) {
                targetTextField.text = hexColor;
            }
        }
    }

    Process {
        id: copyProcess
        property string destName: ""
        function onExited(exitCode) {
            if (exitCode === 0) {
                Settings.change({name: 'currentTheme', value: copyProcess.destName});
            } else {
                console.log("Theme copy failed with exit code:", exitCode);
            }
            Colors.refreshThemes();
        }
    }

    Process {
        id: hyprpickerProcess
        property var targetTextField: null
        command: ["hyprpicker", "-n", "-f", "hex"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var pickedColor = text.trim();
                if (hyprpickerProcess.targetTextField && root.isValidColor(pickedColor)) {
                    hyprpickerProcess.targetTextField.text = pickedColor;
                } else if (pickedColor.length > 0) {
                    console.log("hyprpicker returned an invalid color:", pickedColor);
                }
            }
        }

        function onExited(exitCode) {
            if (exitCode !== 0) {
                console.log("hyprpicker failed with exit code:", exitCode);
            }
            targetTextField = null;
        }
    }

    ColumnLayout {
        id: appearanceSettings
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        SettingsViewTitle {
            title: root.name
        }

        ColorPalette {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
        }

        RowLayout {
            id: topBar
            Layout.fillWidth: true
            Layout.maximumHeight: 40
            spacing: Styles.marginSm

            ComboBoxStyled {
                id: themeComboBox
                model: Colors.availableThemes
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: Colors.availableThemes.indexOf(Colors.currentTheme)
                onActivated: Settings.change({name: 'currentTheme', value: model[currentIndex]})
            }

            ButtonStyled {
                text: "+"
                onClicked: createDialog.visible = true
            }

            ButtonStyled {
                text: ""
                enabled: Colors.availableThemes.length > 1
                onClicked: deleteDialog.visible = true
            }

            ButtonStyled {
                text: ""
                onClicked: renameDialog.visible = true
            }

            ButtonStyled {
                text: ""
                onClicked: Quickshell.execDetached(['bash', '-c', 'xdg-open $XDG_CONFIG_HOME/quickshell/Settings/.data/colors'])
            }
        }

        ScrollView {
            id: view
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: view.width
                spacing: Styles.marginSm

                GeneratedView {
                    category: 'colors'
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                }

                Repeater {
                    model: Object.keys(Colors.userColors).filter(key => ![
                        'onPrimaryContainer', 'inversePrimary',
                        'onSecondaryContainer',
                        'onTertiaryContainer',
                        'onSurfaceVariant',
                        'shadow', 'scrim'
                    ].includes(key))
                    delegate: Rectangle {
                        id: colorEntry

                        required property string modelData
                        required property int index

                        color: Colors.surface
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
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

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            colorPickerDialog.targetTextField = colorTextField;
                                            colorPickerDialog.title = "Select " + colorEntry.modelData + " Color";
                                            colorPickerDialog.initialColor = colorPreview.color;
                                            colorPickerDialog.visible = true;
                                        }
                                    }
                                }

                                Rectangle {
                                    id: validationIndicator
                                    Layout.preferredWidth: 10
                                    Layout.fillHeight: true
                                    radius: Styles.radiusSm
                                    color: root.isValidColor(colorTextField.text) ? Colors.primary : Colors.error
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
                                    id: hyprpickerButton
                                    text: Icons.eyeDropper
                                    enabled: !hyprpickerProcess.running
                                    onClicked: {
                                        hyprpickerProcess.targetTextField = colorTextField;
                                        hyprpickerProcess.running = true;
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
            }
        }
    }
}
