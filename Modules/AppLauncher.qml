pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
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

        implicitWidth: 1000
        implicitHeight: 320

        color: "transparent"

        Component.onCompleted: {
            textInput.focus = true;
            updateFilteredApplications();
            if (DesktopEntries.applications.values.length === 0) {
                DesktopEntries.applications.valuesChanged.connect(onEntriesLoaded);
            }
        }

        function onEntriesLoaded() {
            if (DesktopEntries.applications.values.length > 0) {
                DesktopEntries.applications.valuesChanged.disconnect(onEntriesLoaded);
                updateFilteredApplications();
            }
        }

        property list<DesktopEntry> filteredApplications: []
        property int currentFocusIndex: -1

        Utils {
            id: utils
        }

        Controls {
            id: controls
        }

        function calculateRelevance(app, searchText) {
            if (searchText === "")
                return 1;

            var nameResult = utils.fuzzySearch(searchText, app.name);
            var score = nameResult.matches ? nameResult.score * 3 : 0;

            if (app.genericName) {
                var genericResult = utils.fuzzySearch(searchText, app.genericName);
                if (genericResult.matches)
                    score += genericResult.score * 2;
            }

            if (app.description) {
                var descResult = utils.fuzzySearch(searchText, app.description);
                if (descResult.matches)
                    score += descResult.score * 1;
            }

            if (app.keywords) {
                var keywordsText = app.keywords.join(" ");
                var keywordsResult = utils.fuzzySearch(searchText, keywordsText);
                if (keywordsResult.matches)
                    score += keywordsResult.score * 1.5;
            }

            return score;
        }

        function updateFilteredApplications() {
            var searchText = textInput.text;

            var allApps = DesktopEntries.applications.values;

            filteredApplications = [];

            if (searchText === "") {
                filteredApplications = allApps;
                currentFocusIndex = -1;
                return;
            }

            var scored = [];
            for (var i = 0; i < allApps.length; i++) {
                var score = calculateRelevance(allApps[i], searchText);
                if (score > 0) {
                    scored.push({
                        app: allApps[i],
                        score: score
                    });
                }
            }

            scored.sort(function (a, b) {
                return b.score - a.score;
            });

            var results = [];
            for (var j = 0; j < scored.length; j++) {
                results.push(scored[j].app);
            }

            filteredApplications = results;
            currentFocusIndex = -1;
        }

        function gridNavigationController(event) {
            if (controls.escapePressed(event)) {
                textInput.text = "";
                loader.active = false;
            } else if (controls.enterPressed(event)) {
                appGridView.currentItem.clicked(null);
                loader.active = false;
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

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        ColumnLayout {
            id: base
            anchors.fill: parent
            Rectangle {
                id: searchBar

                implicitHeight: 60
                Layout.fillWidth: true

                color: Colors.surface
                radius: Styles.radiusSm

                readonly property int textSize: 25

                TextFieldStyled {
                    id: textInput
                    placeholderText: 'Search'
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                        margins: Styles.marginSm
                    }
                    onTextChanged: root.updateFilteredApplications()
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

            Rectangle {
                id: appGridBackground

                color: Colors.surface
                radius: Styles.radiusSm

                Layout.fillWidth: true
                Layout.fillHeight: true

                TextStyled {
                    id: noResultsText
                    anchors.centerIn: parent
                    visible: root.filteredApplications.length === 0
                    text: "No results found."
                }

                GridView {
                    id: appGridView

                    clip: true
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm

                    cellWidth: width / 3
                    cellHeight: 60
                    snapMode: GridView.SnapToRow

                    model: root.filteredApplications
                    delegate: ButtonStyled {
                        id: appLaunchButton

                        required property DesktopEntry modelData
                        required property int index

                        implicitWidth: appGridView.cellWidth - Styles.marginSm
                        implicitHeight: appGridView.cellHeight - Styles.marginSm

                        isFocused: index === appGridView.currentIndex

                        onClicked: {
                            modelData.execute();
                            textInput.text = "";
                            loader.active = false;
                        }

                        FlexboxLayout {
                            id: appButtonContent
                            gap: Styles.marginSm

                            anchors {
                                fill: parent
                                margins: Styles.marginSm
                            }

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
