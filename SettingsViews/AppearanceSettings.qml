pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell

import qs.Components
import qs.Settings

ScrollView {
    id: root
    anchors.fill: parent
    anchors.margins: Styles.marginMd
    contentWidth: availableWidth

    function isValidColor(color) {
        return color.match(/^#[0-9A-Fa-f]{6}$/) !== null;
    }

    ConfirmationDialog {
        id: deleteDialog
        onAccepted: {
            var themePath = Colors.directory + GlobalSettings.currentTheme;
            Quickshell.execDetached(['bash', '-c', 'rm "$XDG_CONFIG_HOME/quickshell/Settings/' + themePath + '"']);
            if (Colors.availableThemes.length > 1) {
                var newTheme = Colors.availableThemes.find(t => t !== GlobalSettings.currentTheme);
                if (newTheme) {
                    GlobalSettings.currentTheme = newTheme;
                }
            }
            Colors.refreshThemes();
        }
    }

    TextFieldDialog {
        id: renameDialog
        title: "Rename"
        currentText: GlobalSettings.currentTheme.replace('.json', '')
        onAccepted: {
            var newName = currentText.trim();
            if (newName && newName !== GlobalSettings.currentTheme.replace('.json', '')) {
                if (!newName.endsWith('.json')) {
                    newName += '.json';
                }
                var oldPath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + GlobalSettings.currentTheme;
                var newPath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + newName;
                Quickshell.execDetached(['bash', '-c', 'mv "' + oldPath + '" "' + newPath + '"']);
                GlobalSettings.currentTheme = newName;
                Colors.refreshThemes();
            }
        }
    }

    TextFieldDialog {
        id: createDialog
        title: "Create Theme"
        placeholderText: "Enter new theme name"
        onAccepted: {
            var newName = currentText.trim();
            if (newName) {
                if (!newName.endsWith('.json')) {
                    newName += '.json';
                }
                var sourcePath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + GlobalSettings.currentTheme;
                var destPath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + newName;
                Quickshell.execDetached(['bash', '-c', 'cp "' + sourcePath + '" "' + destPath + '"']);
                GlobalSettings.currentTheme = newName;
                currentText.text = "";
            }
            Colors.refreshThemes();
        }
    }

    ColumnLayout {
        id: appearanceSettings
        spacing: Styles.marginSm
        anchors.fill: parent

        TextStyled {
            text: "Appearance"
            font.pixelSize: Styles.textLg
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Styles.marginSm

            ComboBoxStyled {
                id: themeComboBox
                model: Colors.availableThemes
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: Colors.availableThemes.indexOf(GlobalSettings.currentTheme)
                onActivated: GlobalSettings.currentTheme = model[currentIndex]
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

        Repeater {
            model: Object.keys(Styles.userStyles)
            delegate: Rectangle {
                id: settingEntry

                color: Colors.background
                implicitWidth: parent?.width ?? 0
                implicitHeight: 100
                radius: Styles.radiusSm

                required property string modelData
                required property int index
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm

                    TextStyled {
                        text: settingEntry.modelData
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: textField.implicitHeight + Styles.marginSm * 2

                            color: Colors.backgroundLifted
                            radius: Styles.radiusSm

                            TextFieldStyled {
                                id: textField

                                anchors.fill: parent
                                anchors.margins: Styles.marginSm

                                Component.onCompleted: text = Styles.userStyles[settingEntry.modelData] || ""

                                Connections {
                                    target: Styles
                                    function onUserStylesChanged() {
                                        textField.text = Styles.userStyles[settingEntry.modelData] || "";
                                    }
                                }
                            }
                        }
                        ButtonStyled {
                            text: 'Apply'
                            Layout.fillHeight: true
                            onClicked: {
                                var newStyles = Object.assign({}, Styles.userStyles);
                                if (settingEntry.modelData === "Font Family") {
                                    newStyles[settingEntry.modelData] = text;
                                } else {
                                    newStyles[settingEntry.modelData] = parseInt(textField.text) || 0;
                                }
                                Styles.userStyles = newStyles;
                            }
                        }

                        ButtonStyled {
                            text: 'Reset'
                            Layout.fillHeight: true
                            onClicked: {
                                textField.text = Styles.userStyles[settingEntry.modelData];
                            }
                        }
                    }
                }
            }
        }

        Repeater {
            model: Object.keys(Colors.userColors)
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
    }
}
