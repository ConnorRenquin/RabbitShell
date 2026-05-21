pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Components
import qs.Services

import qs.Settings
import qs.Settings.SettingsViews

FloatingWindowPlus {
    id: root
    color: Colors.surface
    title: 'Settings'

    Component.onCompleted: PatchBay.openSettings.connect(toggle)

    delegate: Rectangle {
        id: base
        anchors.fill: parent
        color: Colors.surface
        focus: true

        Controls {
            id: controls
        }

        Keys.onPressed: event => {
            if (controls.tabPressed(event) || controls.backtabPressed(event)) {
                event.accepted = true;

                // Filter children to only include actual views that have a 'name' property
                var views = [];
                for (var i = 0; i < settingsModuleUi.children.length; i++) {
                    var child = settingsModuleUi.children[i];
                    if (child.name !== undefined) {
                        views.push(child);
                    }
                }

                var currentIndex = -1;
                for (var i = 0; i < views.length; i++) {
                    if (views[i].visible) {
                        currentIndex = i;
                        break;
                    }
                }

                if (currentIndex !== -1) {
                    views[currentIndex].visible = false;
                    var nextIndex;
                    if (controls.backtabPressed(event)) {
                        nextIndex = (currentIndex - 1 + views.length) % views.length;
                    } else {
                        nextIndex = (currentIndex + 1) % views.length;
                    }
                    views[nextIndex].visible = true;

                    // Find the index of the selected view in the ListView's model
                    var originalIndex = settingsModuleUi.children.indexOf(views[nextIndex]);
                    if (originalIndex !== -1) {
                        settingModules.positionViewAtIndex(originalIndex, ListView.Contain);
                    }
                }
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
                color: Colors.background
                Layout.preferredWidth: 300
                Layout.fillWidth: true
                AboutSettingsView {
                    readonly property string name:  Icons.info + ' About'
                    anchors.fill: parent
                }
                BluetoothSettingsView {
                    readonly property string name: Icons.bluetooth + ' Bluetooth'
                    anchors.fill: parent
                }
                AppearanceSettingsView {
                    readonly property string name: Icons.colors + ' Colors'
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
                ScrollView {
                    readonly property string name:  Icons.misc + ' Misc'
                    anchors.fill: parent
                    contentWidth: availableWidth
                    GeneratedView {
                        category: 'misc'
                        width: parent.width
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
