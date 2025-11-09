import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.Constants
import qs.Components

PanelWindow {
    id: root

    implicitWidth: 1000
    implicitHeight: 275
    focusable: true
    color: "transparent"
    visible: showing

    property bool showing: false
    property var filteredApplications: []

    GlobalShortcut {
        name: "appsearch"
        onPressed: {
            root.showing = !root.showing;
            if (root.showing) {
                textInput.forceActiveFocus();
            }
        }
    }

    HyprlandFocusGrab {
        active: root.showing
        windows: [root]
        onCleared: {
            root.showing = false;
        }
    }

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
        var allApps = DesktopEntries.applications.values;
        var searchText = textInput.text;

        if (searchText === "") {
            filteredApplications = allApps.slice(0, appGrid.columns * appGrid.rows);
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
        var maxResults = Math.min(16, scored.length);
        for (var j = 0; j < maxResults; j++) {
            results.push(scored[j].app);
        }

        filteredApplications = results;
    }

    Component.onCompleted: {
        updateFilteredApplications();
    }

    // Searchbar
    Rectangle {
        id: searchBar
        readonly property int textSize: 25
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        implicitHeight: textInput.implicitHeight + 30
        color: Colors.bgDim
        radius: Styles.radius0

        TextInput {
            id: textInput
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Styles.margin
            anchors.rightMargin: Styles.margin

            font.pixelSize: searchBar.textSize
            color: Colors.fg
            focus: true
            selectByMouse: true
            cursorVisible: true
            verticalAlignment: TextInput.AlignVCenter

            onTextChanged: updateFilteredApplications()

            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Escape) {
                    text = "";
                    root.showing = false;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (filteredApplications.length > 0) {
                        Quickshell.execDetached(["bash", "-c", filteredApplications[0].execString]);
                        text = "";
                        root.showing = false;
                    }
                }
            }
        }

        Text {
            anchors.left: textInput.left
            anchors.verticalCenter: textInput.verticalCenter
            text: "Search"
            font.pixelSize: searchBar.textSize
            color: Colors.fg
            opacity: 0.4
            visible: textInput.text === ""
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Applications Grid
    Grid {
        id: appGrid
        anchors {
            top: searchBar.bottom
            left: parent.left
            right: parent.right
            topMargin: Styles.margin
        }

        columns: 3
        columnSpacing: Styles.margin

        rows: 4
        rowSpacing: Styles.margin

        Repeater {
            model: filteredApplications

            Rectangle {
                id: menuItemBackground
                implicitWidth: searchBar.width / appGrid.columns - (Styles.margin / appGrid.columns * 2)
                implicitHeight: menuItem.implicitHeight + Styles.margin
                color: mouseArea.containsMouse ? Colors.bg1 : Colors.bg0
                radius: Styles.radius0

                Behavior on color {
                    ColorAnimation {
                        duration: 250
                    }
                }

                RowLayout {
                    id: menuItem
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.margins: Styles.margin
                    spacing: 10

                    IconImage {
                        implicitWidth: 32
                        implicitHeight: 32
                        source: Quickshell.iconPath(modelData.icon)
                    }

                    TextStyled {
                        text: modelData.name
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", modelData.execString]);
                    }
                }
            }
        }
    }
}
