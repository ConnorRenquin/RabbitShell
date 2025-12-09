import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.Constants
import qs.Components
import qs.Services

Loader {
    id: loader

    active: false

    GlobalShortcut {
        name: "appsearch"
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
        }

        property var allApps: DesktopEntries.applications.values
        property var filteredApplications: []
        property int currentFocusIndex: -1

        function calculateRelevance(app, searchText) {
            if (searchText === "")
                return 1;

            var search = searchText.toLowerCase();
            var name = app.name.toLowerCase();

            if (name === search)
                return 1000;
            if (name.startsWith(search))
                return 500;

            var score = 0;
            if (name.indexOf(search) !== -1)
                score = 300;

            if (app.genericName && app.genericName.toLowerCase().indexOf(search) !== -1)
                score += 200;
            if (app.description && app.description.toLowerCase().indexOf(search) !== -1)
                score += 100;
            if (app.keywords && app.keywords.join(" ").toLowerCase().indexOf(search) !== -1)
                score += 150;

            return score;
        }

        function updateFilteredApplications() {
            var searchText = textInput.text;

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
            if ([Qt.Key_Escape].includes(event.key)) {
                textInput.text = "";
                loader.active = false;
            } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                appGridView.currentItem.clicked(null);
                loader.active = false;
            } else if (event.key === Qt.Key_Down) {
                appGridView.moveCurrentIndexDown();
            } else if (event.key === Qt.Key_Up) {
                appGridView.moveCurrentIndexUp();
            } else if (event.key === Qt.Key_Left) {
                appGridView.moveCurrentIndexLeft();
            } else if (event.key === Qt.Key_Right) {
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

                color: Colors.bgDim
                radius: Styles.radius0

                readonly property int textSize: 25

                TextInput {
                    id: textInput
                    font.pixelSize: searchBar.textSize
                    color: Colors.fg
                    selectByMouse: true
                    cursorVisible: true
                    verticalAlignment: TextInput.AlignVCenter

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                        margins: Styles.marginSm
                    }

                    onTextChanged: root.updateFilteredApplications()

                    Keys.onPressed: event => root.gridNavigationController(event)
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onClicked: {
                            textInput.forceActiveFocus();
                        }
                    }
                }

                TextStyled {
                    id: placeholderText
                    anchors.left: textInput.left
                    anchors.verticalCenter: textInput.verticalCenter
                    text: "Search"
                    opacity: 0.4
                    visible: textInput.text === ""
                }

                Rectangle {
                    id: clockBackground
                    implicitHeight: parent.height - Styles.marginLg
                    implicitWidth: clock.implicitWidth + Styles.marginLg
                    anchors.margins: Styles.marginMd
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.orange
                    radius: Styles.radiusLg
                    TextStyled {
                        id: clock
                        anchors.centerIn: parent
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.bgDim
                        text: Time.timeShort
                    }
                }
            }

            Rectangle {
                color: Colors.bgDim
                radius: Styles.radiusSm

                Layout.fillWidth: true
                Layout.fillHeight: true

                TextStyledNoAnchors {
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

                    model: filteredApplications
                    delegate: ButtonStyled {
                        id: menuButton

                        implicitWidth: appGridView.cellWidth - Styles.marginSm
                        implicitHeight: appGridView.cellHeight - Styles.marginSm

                        radius: Styles.radiusSm

                        isFocused: index === appGridView.currentIndex

                        onClicked: {
                            Quickshell.execDetached(["bash", "-c", modelData.execString]);
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
                                source: Quickshell.iconPath(modelData.icon) ?? ""
                            }

                            TextStyled {
                                id: appName
                                text: modelData.name
                                color: menuButton.isFocused ? Colors.bg1 : Colors.fg
                            }
                        }
                    }
                }
            }
        }
    }
}
