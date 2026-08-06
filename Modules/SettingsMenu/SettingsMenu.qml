pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.Components
import qs.Components.Plus
import qs.Components.Styled
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
        property bool sideButtonsCollapsed: false
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

        property list<SettingsViewEntry> settingsViews: [
            SettingsViewEntry {
                id: aboutSettingsViewEntry
                name: Icons.info + ' About'
                view: Component {
                    AboutSettingsView {
                        name: aboutSettingsViewEntry.name
                        anchors.fill: parent
                    }
                }
            },

            SettingsViewEntry {
                id: bluetoothSettingsViewEntry
                name: Icons.bluetooth + ' Bluetooth'
                view: Component {
                    BluetoothSettingsView {
                        name: bluetoothSettingsViewEntry.name
                        anchors.fill: parent
                    }
                }
            },
            SettingsViewEntry {
                id: networkSettingsViewEntry
                name: Icons.network + ' Network'
                view: Component {
                    NetworkSettingsView {
                        name: networkSettingsViewEntry.name
                        anchors.fill: parent
                    }
                }
            },
            SettingsViewEntry {
                id: appearanceSettingsViewEntry
                name: Icons.appearance + ' Appearance'
                view: Component {
                    GeneralView {
                        name: appearanceSettingsViewEntry.name
                        category: 'appearance'
                    }
                }
            },
            SettingsViewEntry {
                id: colorsSettingsViewEntry
                name: Icons.colors + ' Colors'
                view: Component {
                    ColorsSettingsView {
                        name: colorsSettingsViewEntry.name
                        anchors.fill: parent
                    }
                }
            },
            SettingsViewEntry {
                id: pipewireSettingsViewEntry
                name: Icons.audio + ' Audio'
                view: Component {
                    PipewireSettingsView {
                        name: pipewireSettingsViewEntry.name
                        anchors.fill: parent
                    }
                }
            },
            SettingsViewEntry {
                id: displaySettingsViewEntry
                name: Icons.display + ' Display'
                view: Component {
                    DisplaySettingsView {
                        name: displaySettingsViewEntry.name
                        anchors.fill: parent
                    }
                }
            },
            SettingsViewEntry {
                id: wallpaperSettingsViewEntry
                name: Icons.wallpaper + ' Wallpaper'
                view: Component {
                    WallpaperSettingsView {
                        name: wallpaperSettingsViewEntry.name
                        anchors.fill: parent
                    }
                }
            },
            SettingsViewEntry {
                id: miscSettingsViewEntry
                name: Icons.misc + ' Misc'
                view: Component {
                    GeneralView {
                        name: miscSettingsViewEntry.name
                        category: 'misc'
                    }
                }
            },
            SettingsViewEntry {
                id: cheatsheetSettingsViewEntry
                name: Icons.knowledge + ' Knowledge'
                view: Component {
                    Cheatsheet {
                        name: cheatsheetSettingsViewEntry.name
                        anchors.fill: parent
                    }
                }
            }
        ]

        function selectTabByIndex(index) {
            if (settingsViews.length === 0)
                return;

            if (index < 0 || index >= settingsViews.length)
                index = 0;

            persisted.selectedTabIndex = index;
            settingModules.positionViewAtIndex(index, ListView.Contain);
        }

        function tabIcon(name) {
            var parts = name.split(' ');
            return parts.length > 0 ? parts[0] : name;
        }

        Keys.onPressed: event => {
            if (controls.tabPressed(event) || controls.backtabPressed(event)) {
                event.accepted = true;

                var viewCount = settingsViews.length;
                if (viewCount === 0)
                    return;

                var currentIndex = persisted.selectedTabIndex;
                var nextIndex = controls.backtabPressed(event)
                    ? (currentIndex - 1 + viewCount) % viewCount
                    : (currentIndex + 1) % viewCount;
                selectTabByIndex(nextIndex);
            }
        }

        RowLayout {
            id: mainLayout
            anchors.fill: parent


            ColumnLayout {
                id: sideButtons
                Layout.fillHeight: true
                Layout.margins: Styles.marginSm
                Layout.maximumWidth: persisted.sideButtonsCollapsed ? minWidth : Styles.marginLg * 8
                spacing: Styles.marginSm

                property int minWidth: 40

                ListView {
                    id: settingModules
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    spacing: Styles.marginSm
                    model: base.settingsViews
                    delegate: ButtonStyled {
                        required property int index
                        required property SettingsViewEntry modelData
                        textMargin: 5
                        textAlignment: persisted.sideButtonsCollapsed ? Text.AlignHCenter : Text.AlignLeft
                        width: ListView.view.width
                        text: persisted.sideButtonsCollapsed ? base.tabIcon(modelData.name) : modelData.name
                        isFocused: index === persisted.selectedTabIndex
                        onClicked: base.selectTabByIndex(index)
                    }
                }

                Rectangle {
                    height: 2
                    radius: Styles.radiusSm
                    Layout.fillWidth: true
                    color: Colors.background
                }

                ButtonStyled {
                    id: collapseButton
                    Layout.preferredHeight: implicitHeight
                    Layout.preferredWidth: sideButtons.minWidth
                    text: persisted.sideButtonsCollapsed ? Icons.sidebarClosed : Icons.sidebarOpen
                    onClicked: persisted.sideButtonsCollapsed = !persisted.sideButtonsCollapsed
                }

            }
            Rectangle {
                id: settingsModuleUi
                Layout.fillHeight: true
                color: Colors.surface
                Layout.preferredWidth: 300
                Layout.fillWidth: true
                Repeater {
                    model: base.settingsViews
                    delegate: SettingsViewLoader {
                        required property int index
                        required property SettingsViewEntry modelData
                        name: modelData.name
                        sourceComponent: modelData.view
                        visible: index === persisted.selectedTabIndex
                    }
                }
            }
        }

        Component.onCompleted: Qt.callLater(() => selectTabByIndex(persisted.selectedTabIndex))
    }
    component SettingsViewEntry: QtObject {
        required property string name
        required property Component view
    }

    component SettingsViewLoader: Loader {
        required property string name
        anchors.fill: parent
        active: visible
        visible: false
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
