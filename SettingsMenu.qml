pragma ComponentBehavior: Bound

import Quickshell

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services
import qs.SettingsViews

FloatingWindow {
    id: root
    color: Colors.background

    title: 'Settings'
    visible: false

    Component.onCompleted: {
        PatchBay.openThemeSelector.connect(() => root.visible = !root.visible);
        settingsModuleUi.children.forEach(item => item.visible = false);
        settingsModuleUi.children[0].visible = true;
    }
    RowLayout {
        id: mainLayout
        anchors.fill: parent
        ListView {
            id: settingModules
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Styles.marginSm
            Layout.preferredWidth: 50
            spacing: Styles.marginSm
            model: settingsModuleUi.children
            delegate: ButtonStyled {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                width: parent.width
                text: modelData.name
                isFocused: modelData.visible
                onClicked: {
                    settingsModuleUi.children.forEach(item => item.visible = false);
                    modelData.visible = true;
                }
            }
        }
        Rectangle {
            id: settingsModuleUi
            Layout.fillHeight: true
            color: Colors.backgroundLifted
            Layout.preferredWidth: 300
            Layout.fillWidth: true
            PipewireSettingsView {
                readonly property string name: 'Audio'
                anchors.fill: parent
            }
            DisplaySettingsView {
                readonly property string name: 'Display'
                anchors.fill: parent
            }
            WallpaperSettingsView {
                readonly property string name: 'Wallpaper'
                anchors.fill: parent
            }
            ScrollView {
                readonly property string name: 'Appearance'
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                contentWidth: availableWidth
                ColumnLayout {
                    id: appearanceSettings
                    spacing: Styles.marginSm
                    anchors.fill: parent
                    ThemeSettingsView {
                        Layout.preferredHeight: 300
                        Layout.fillWidth: true
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
            Cheatsheet {
                readonly property string name: 'Cheatsheet'
                anchors.fill: parent
            }
        }
    }
}
