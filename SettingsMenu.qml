pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services
import qs.SettingsViews

Loader {
    id: loader

    active: false

    function toggle() {
        loader.active = !loader.active;
    }

    Component.onCompleted: PatchBay.openSettings.connect(toggle)

    sourceComponent: FloatingWindow {
        id: root
        color: Colors.background
        title: 'Settings'

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        Rectangle {
            id: base
            anchors.fill: parent
            color: Colors.background
            focus: true

            Keys.onPressed: event => {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    loader.active = false;
                }
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
                        textAlignment: Text.AlignLeft
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
                    color: Colors.backgroundLighter
                    Layout.preferredWidth: 300
                    Layout.fillWidth: true
                    UpdateSettingsView {
                        readonly property string name:  Icons.info + ' About'
                        anchors.fill: parent
                    }
                    BluetoothSettingsView {
                        readonly property string name: Icons.bluetooth + ' Bluetooth'
                        anchors.fill: parent
                    }
                    AppearanceSettingsView {
                        readonly property string name: Icons.appearance + ' Appearance'
                        anchors.fill: parent
                    }
                    PipewireSettingsView {
                        readonly property string name: Icons.audio + ' Audio'
                        anchors.fill: parent
                    }
                    DisplaySettingsView {
                        readonly property string name: Icons.display + ' Display'
                        anchors.fill: parent
                    }
                    WallpaperSettingsView {
                        readonly property string name: Icons.wallpaper + ' Wallpaper'
                        anchors.fill: parent
                    }
                    Cheatsheet {
                        readonly property string name: Icons.cheatsheet + ' Cheatsheet'
                        anchors.fill: parent
                    }
                }
            }
        }

        Component.onCompleted: {
            settingsModuleUi.children.forEach(item => item.visible = false);
            settingsModuleUi.children[0].visible = true;
        }
    }
}
