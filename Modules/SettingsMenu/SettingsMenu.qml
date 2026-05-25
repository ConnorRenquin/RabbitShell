pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.Components
import qs.Services
import qs.Helpers
import qs.Settings
import qs.Modules.SettingsMenu.SettingsViews
import qs.Modules.SettingsMenu.SettingsViews.Components

FloatingWindowPlus {
    id: root
    color: Colors.surface
    title: 'Settings'
    persistId: "settings-menu"

    PersistentProperties {
        id: persisted
        reloadableId: "settings-menu-state"

        property int selectedTabIndex: 0
    }

    Component.onCompleted: PatchBay.openSettings.connect(toggle)

    delegate: Rectangle {
        id: base
        anchors.fill: parent
        color: Colors.surface
        focus: true

        Controls {
            id: controls
        }

        function childIndexOf(item) {
            for (var i = 0; i < settingsModuleUi.children.length; i++) {
                if (settingsModuleUi.children[i] === item)
                    return i;
            }

            return -1;
        }

        function selectTabByIndex(index) {
            var children = settingsModuleUi.children;
            if (children.length === 0)
                return;

            if (index < 0 || index >= children.length || children[index].name === undefined)
                index = 0;

            children.forEach(item => {
                if (item.name !== undefined)
                    item.visible = false;
            });

            children[index].visible = true;
            persisted.selectedTabIndex = index;
            settingModules.positionViewAtIndex(index, ListView.Contain);
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
                    var originalIndex = childIndexOf(views[nextIndex]);
                    if (originalIndex !== -1)
                        selectTabByIndex(originalIndex);
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
                        base.selectTabByIndex(base.childIndexOf(modelData));
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
                    name: Icons.info + ' About'
                    anchors.fill: parent
                }
                HyprlandSettingsView {
                    name: Icons.hyprland + ' Hyprland'
                    anchors.fill: parent
                }
                BluetoothSettingsView {
                    name: Icons.bluetooth + ' Bluetooth'
                    anchors.fill: parent
                }
                NetworkSettingsView {
                    name: Icons.network + ' Network'
                    anchors.fill: parent
                }
                GeneralView {
                    name: Icons.appearance + ' Appearance'
                    category: 'appearance'
                }
                ColorsSettingsView {
                    name: Icons.colors + ' Colors'
                    anchors.fill: parent
                }
                PipewireSettingsView {
                    name: Icons.audio + ' Audio'
                    anchors.fill: parent
                }
                DisplaySettingsView {
                    name: Icons.display + ' Display'
                    anchors.fill: parent
                }
                WallpaperSettingsView {
                    name: Icons.wallpaper + ' Wallpaper'
                    anchors.fill: parent
                }
                GeneralView {
                    name: Icons.misc + ' Misc'
                    category: 'misc'
                }
                Cheatsheet {
                    name: Icons.cheatsheet + ' Cheatsheet'
                    anchors.fill: parent
                }
            }
        }

        Component.onCompleted: Qt.callLater(() => selectTabByIndex(persisted.selectedTabIndex))
    }
    component GeneralView: ScrollView {
        id: view
        required property string name
        property alias category: genView.category
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        contentWidth: availableWidth
        ColumnLayout {
            anchors.fill: parent
            SettingsViewTitle {
                title: view.name
            }
            GeneratedView {
                id: genView
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
