pragma ComponentBehavior: Bound

import Quickshell

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants
import qs.Services
import qs.Settings

FloatingWindow {
    id: root
    color: Colors.background
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
            ThemeSettings {
                readonly property string name: 'Theme'
                anchors.fill: parent
            }
            ColorSettings {
                readonly property string name: 'Colors'
                anchors.fill: parent
            }
            StyleSettings {
                readonly property string name: 'Styles'
                anchors.fill: parent
            }
        }
    }
}
