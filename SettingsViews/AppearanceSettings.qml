pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell

import qs.Components
import qs.Settings
import qs.SettingsViews

ScrollView {
    anchors.fill: parent
    anchors.margins: Styles.marginMd
    contentWidth: availableWidth

    // Delete confirmation dialog
    Dialog {
        id: deleteDialog
        anchors.centerIn: parent
        modal: true
        title: "Delete Theme"
        standardButtons: Dialog.Yes | Dialog.No

        ColumnLayout {
            spacing: Styles.marginMd
            TextStyled {
                text: "Are you sure you want to delete the theme:"
                Layout.fillWidth: true
            }
            TextStyled {
                text: GlobalSettings.currentTheme
                font.bold: true
                color: Colors.error
                Layout.fillWidth: true
            }
            TextStyled {
                text: "This action cannot be undone."
                font.pixelSize: Styles.textSm
                color: Colors.warning
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            var themePath = Colors.directory + GlobalSettings.currentTheme;
            Quickshell.execDetached(['bash', '-c', 'rm "$XDG_CONFIG_HOME/quickshell/Settings/' + themePath + '"']);
            // Switch to first available theme after deletion
            if (Colors.availableThemes.length > 1) {
                var newTheme = Colors.availableThemes.find(t => t !== GlobalSettings.currentTheme);
                if (newTheme) {
                    GlobalSettings.currentTheme = newTheme;
                }
            }
            Colors.refreshThemes()
        }
    }

    // Rename dialog
    Dialog {
        id: renameDialog
        anchors.centerIn: parent
        modal: true
        title: "Rename Theme"
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            spacing: Styles.marginMd
            TextStyled {
                text: "Current name: " + GlobalSettings.currentTheme
                Layout.fillWidth: true
            }
            TextStyled {
                text: "New name:"
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: Colors.backgroundLifted
                border.color: Colors.backgroundHighlighted
                border.width: 1
                radius: Styles.radiusSm

                TextFieldStyled {
                    id: renameField
                    anchors.fill: parent
                    placeholderText: "Enter new theme name"
                    text: GlobalSettings.currentTheme.replace('.json', '')

                    onAccepted: renameDialog.accept()
                }
            }
        }

        onAccepted: {
            var newName = renameField.text.trim();
            if (newName && newName !== GlobalSettings.currentTheme.replace('.json', '')) {
                if (!newName.endsWith('.json')) {
                    newName += '.json';
                }
                var oldPath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + GlobalSettings.currentTheme;
                var newPath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + newName;
                Quickshell.execDetached(['bash', '-c', 'mv "' + oldPath + '" "' + newPath + '"']);
                GlobalSettings.currentTheme = newName;
                Colors.refreshThemes()
            }
        }

        onOpened: {
            renameField.selectAll();
            renameField.forceActiveFocus();
        }
    }

    // Create new theme dialog
    Dialog {
        id: createDialog
        anchors.centerIn: parent
        modal: true
        title: "Create New Theme"
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            spacing: Styles.marginMd
            TextStyled {
                text: "New Theme"
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: Colors.backgroundLifted
                border.color: Colors.backgroundHighlighted
                radius: Styles.radiusSm

                TextFieldStyled {
                    id: createField
                    anchors.fill: parent
                    placeholderText: "my-theme"

                    onAccepted: createDialog.accept()
                }
            }
        }

        onAccepted: {
            var newName = createField.text.trim();
            if (newName) {
                if (!newName.endsWith('.json')) {
                    newName += '.json';
                }
                var sourcePath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + GlobalSettings.currentTheme;
                var destPath = '$XDG_CONFIG_HOME/quickshell/Settings/' + Colors.directory + newName;
                Quickshell.execDetached(['bash', '-c', 'cp "' + sourcePath + '" "' + destPath + '"']);
                GlobalSettings.currentTheme = newName;
                createField.text = "";
            }
            Colors.refreshThemes()
        }

        onOpened: {
            createField.text = "";
            createField.forceActiveFocus();
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
                onClicked: createDialog.open()
            }

            ButtonStyled {
                text: ""
                enabled: Colors.availableThemes.length > 1
                onClicked: deleteDialog.open()
            }

            ButtonStyled {
                text: ""
                onClicked: renameDialog.open()
            }

            ButtonStyled {
                text: ""
                onClicked: Quickshell.execDetached(['bash', '-c', 'xdg-open $XDG_CONFIG_HOME/quickshell/Settings/.data/colors']);
            }
        }

        ColorSettingsView {
            Layout.preferredHeight: 400
            Layout.fillWidth: true
        }

        StyleSettingsView {
            Layout.fillHeight: true
            Layout.preferredHeight: 300
            Layout.fillWidth: true
        }
    }
}
