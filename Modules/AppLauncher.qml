pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Helpers
import qs.Components
import qs.Components.Styled
import qs.Services

Loader {
    id: loader

    active: false

    Component.onCompleted: PatchBay.openAppLauncher.connect(() => active = !active)

    GlobalShortcut {
        name: "applauncher"
        onPressed: active = !active
    }

    sourceComponent: PanelWindow {
        id: root

        implicitWidth: 800
        implicitHeight: 380

        color: "transparent"

        property bool offset: Settings.register({
            name: 'offsetScreenAppLauncher',
            value: true,
            category: 'appearance'
        }).value
        property bool center: Settings.register({
            name: 'centerScreenAppLauncher',
            value: true,
            category: 'appearance'
        }).value
        property bool topBar: Settings.get('barPosition').value
        property string selectedCategory: "all"
        readonly property var categoryDefinitions: [
            { category: "AudioVideo", icon: Icons.categoryAudioVideo },
            { category: "Development", icon: Icons.categoryDevelopment },
            { category: "Education", icon: Icons.categoryEducation },
            { category: "HealthFitness", icon: Icons.categoryHealthFitness },
            { category: "Game", icon: Icons.categoryGame },
            { category: "Graphics", icon: Icons.categoryGraphics },
            { category: "Network", icon: Icons.categoryNetwork },
            { category: "Office", icon: Icons.categoryOffice },
            { category: "Science", icon: Icons.categoryScience },
            { category: "Settings", icon: Icons.categorySettings },
            { category: "System", icon: Icons.categorySystem },
            { category: "Utility", icon: Icons.categoryUtility }
        ]
        readonly property var availableCategoryDefinitions: categoryDefinitions.filter(definition => System.applicationCategories.includes(definition.category))
        anchors.bottom: !topBar && !center
        anchors.top: topBar && !center
        anchors.left: offset
        margins.left: 10
        margins.top: 70
        margins.bottom: 70
        exclusionMode: ExclusionMode.Ignore

        Component.onCompleted: {
            textInput.focus = true;
            System.setApplicationCategory("all");
            System.setApplicationSearchText(textInput.text);
        }

        Controls {
            id: controls
        }

        function gridNavigationController(event) {
            if (controls.tabPressed(event)) {
                cycleCategory(1);
                event.accepted = true;
            } else if (controls.backtabPressed(event)) {
                cycleCategory(-1);
                event.accepted = true;
            } else if (controls.escapePressed(event)) {
                textInput.text = "";
                loader.active = false;
            } else if (controls.enterPressed(event)) {
                if (appGridView.currentIndex >= 0 && appGridView.currentIndex < System.filteredApplications.length) {
                    System.launchApplication(System.filteredApplications[appGridView.currentIndex]);
                    textInput.text = "";
                    loader.active = false;
                }
            } else if (controls.downPressed(event, true)) {
                appGridView.moveCurrentIndexDown();
            } else if (controls.upPressed(event, true)) {
                appGridView.moveCurrentIndexUp();
            } else if (controls.leftPressed(event, true)) {
                appGridView.moveCurrentIndexLeft();
            } else if (controls.rightPressed(event, true)) {
                appGridView.moveCurrentIndexRight();
            }
        }

        function selectCategory(category) {
            selectedCategory = category;
            System.setApplicationCategory(category);
            appGridView.currentIndex = System.filteredApplications.length > 0 ? 0 : -1;
        }

        function cycleCategory(offset) {
            var categories = ["all"].concat(availableCategoryDefinitions.map(definition => definition.category));
            var currentIndex = categories.indexOf(selectedCategory);
            selectCategory(categories[(currentIndex + offset + categories.length) % categories.length]);
        }

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        ColumnLayout {
            id: base
            anchors.fill: parent
            spacing: Styles.marginSm

            RowLayout {
                id: searchRow

                Layout.maximumHeight: 60
                spacing: Styles.marginSm

                Rectangle {
                    id: searchBar

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    color: Colors.surface
                    radius: Styles.radiusSm

                    readonly property int textSize: 25

                    TextFieldStyled {
                        id: textInput
                        placeholderText: 'Search'
                        implicitHeight: parent.height - (Styles.marginSm * 2)
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: clockBackground.left
                            margins: Styles.marginSm
                        }
                        onTextChanged: {
                            System.setApplicationSearchText(text);
                            appGridView.currentIndex = System.filteredApplications.length > 0 ? 0 : -1;
                        }
                        Keys.onPressed: event => root.gridNavigationController(event)
                    }

                    Rectangle {
                        id: clockBackground
                        implicitHeight: parent.height - Styles.marginLg
                        implicitWidth: clock.implicitWidth + Styles.marginLg
                        anchors.margins: Styles.marginMd
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: Qt.darker(Colors.surface, Colors.darker)
                        radius: Styles.radiusLg
                        TextStyled {
                            id: clock
                            anchors.centerIn: parent
                            anchors.verticalCenter: parent.verticalCenter
                            text: Time.timeShort
                        }
                    }
                }

                ButtonStyled {
                    id: settingsButton
                    Layout.preferredWidth: searchRow.height
                    Layout.fillHeight: true
                    text: Icons.settingsCog
                    defaultColor: Colors.surface
                    onClicked: {
                        textInput.text = "";
                        loader.active = false;
                        PatchBay.openSettings();
                    }
                }

                ButtonStyled {
                    id: powerButton
                    Layout.preferredWidth: searchRow.height
                    Layout.fillHeight: true
                    text: Icons.power
                    defaultColor: Colors.surface
                    onClicked: {
                        textInput.text = "";
                        loader.active = false;
                        PatchBay.openPowerMenu();
                    }
                }
            }

            Rectangle {
                id: categoryRowBackground

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: categoryRow.implicitWidth + Styles.marginSm
                Layout.preferredHeight: Styles.marginLg + Styles.marginMd

                color: Colors.surface
                radius: Styles.radiusSm

                RowLayout {
                    id: categoryRow

                    anchors.centerIn: parent
                    spacing: Styles.marginXS

                    ButtonStyled {
                        Layout.preferredWidth: Styles.marginLg + Styles.marginSm
                        Layout.preferredHeight: Styles.marginLg + Styles.marginSm

                        text: Icons.infinity
                        pointSize: Styles.textLg
                        isFocused: root.selectedCategory === "all"
                        defaultColor: isFocused ? Colors.primary : Colors.background
                        textColor: isFocused ? Colors.onPrimary : Colors.onBackground
                        Accessible.name: "All applications"
                        onClicked: root.selectCategory("all")
                    }

                    Repeater {
                        model: root.availableCategoryDefinitions

                        delegate: ButtonStyled {
                            required property var modelData

                            Layout.preferredWidth: Styles.marginLg + Styles.marginSm
                            Layout.preferredHeight: Styles.marginLg + Styles.marginSm

                            text: modelData.icon
                            pointSize: Styles.textLg
                            isFocused: root.selectedCategory === modelData.category
                            defaultColor: isFocused ? Colors.primary : Colors.background
                            textColor: isFocused ? Colors.onPrimary : Colors.onBackground
                            Accessible.name: modelData.category
                            onClicked: root.selectCategory(modelData.category)
                        }
                    }
                }
            }

            Rectangle {
                id: appGridBackground

                color: Colors.surface
                radius: Styles.radiusSm

                Layout.fillWidth: true
                Layout.fillHeight: true

                TextStyled {
                    id: noResultsText
                    anchors.centerIn: parent
                    visible: System.filteredApplications.length === 0
                    text: "no results found"
                }

                GridView {
                    id: appGridView

                    clip: true
                    anchors.fill: parent

                    cellWidth: width / 3
                    cellHeight: height / 4
                    snapMode: GridView.SnapToRow

                    model: System.filteredApplications
                    delegate: Item {
                        id: appLaunchButton

                        required property var modelData
                        required property int index

                        implicitWidth: appGridView.cellWidth
                        implicitHeight: appGridView.cellHeight
                        ButtonStyled {

                            isFocused: appLaunchButton.index === appGridView.currentIndex
                            anchors.fill: parent
                            anchors.margins: Styles.marginSm / 2

                            onClicked: {
                                System.launchApplication(appLaunchButton.modelData);
                                textInput.text = "";
                                loader.active = false;
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Styles.marginSm
                                spacing: 10
                                IconImage {
                                    id: appIcon
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    source: Quickshell.iconPath(appLaunchButton.modelData.icon, "applications-other")
                                }

                                TextStyled {
                                    id: appName
                                    Layout.fillWidth: true
                                    text: appLaunchButton.modelData.name
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
