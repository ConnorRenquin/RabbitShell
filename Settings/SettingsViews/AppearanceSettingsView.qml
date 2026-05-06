pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.Components
import qs.Settings

Rectangle {
    id: root
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

    Process {
        id: copyProcess
        property string destName: ""
        onExited: (code) => {
            if (code === 0) {
                Settings.change({name: 'currentTheme', value: copyProcess.destName});
            } else {
                console.log("Theme copy failed with exit code:", code);
            }
            Colors.refreshThemes();
        }
    }

    ColumnLayout {
        id: appearanceSettings
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginLg

        TextStyled {
            text: "Appearance"
            font.pointSize: Styles.textLg
        }

        RowLayout {
            id: topBar
            Layout.fillWidth: true
            Layout.maximumHeight: 30
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

                Repeater {
                    model: Object.keys(Colors.userColors)
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
