import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.Constants
import qs.Components
import qs.Services

PanelWindow {
    id: root

    implicitWidth: 1000
    implicitHeight: 305
    focusable: true
    color: "transparent"
    visible: showing

    Component.onCompleted: updateFilteredApplications()

    property bool showing: false
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
        var allApps = DesktopEntries.applications.values;
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

    function executeCurrentItem() {
        if (currentFocusIndex >= 0 && currentFocusIndex < filteredApplications.length) {
            Quickshell.execDetached(["bash", "-c", filteredApplications[currentFocusIndex].execString]);
            textInput.text = "";
            root.showing = false;
        }
    }

    function navigateGrid(direction) {
        var maxIndex = filteredApplications.length - 1;

        if (currentFocusIndex === -1) {
            currentFocusIndex = 0;
            appGridView.positionViewAtIndex(0, GridView.Beginning);
            return;
        }

        var columns = 3;
        var row = Math.floor(currentFocusIndex / columns);
        var col = currentFocusIndex % columns;

        if (direction === "up") {
            if (row > 0) {
                currentFocusIndex = Math.max(0, currentFocusIndex - columns);
                appGridView.positionViewAtIndex(currentFocusIndex, GridView.Contain);
            }
        } else if (direction === "down") {
            var newIndex = currentFocusIndex + columns;
            if (newIndex <= maxIndex) {
                currentFocusIndex = newIndex;
            } else if (currentFocusIndex < maxIndex) {
                currentFocusIndex = maxIndex;
            }
            appGridView.positionViewAtIndex(currentFocusIndex, GridView.Contain);
        } else if (direction === "left") {
            if (col > 0) {
                currentFocusIndex = Math.max(0, currentFocusIndex - 1);
                appGridView.positionViewAtIndex(currentFocusIndex, GridView.Contain);
            }
        } else if (direction === "right") {
            if (col < columns - 1 && currentFocusIndex < maxIndex) {
                currentFocusIndex = Math.min(maxIndex, currentFocusIndex + 1);
                appGridView.positionViewAtIndex(currentFocusIndex, GridView.Contain);
            }
        }
    }

    function gridNavigationController(event) {
        console.log();
        if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
            text = "";
            root.showing = false;
            event.accepted = true;
        } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
            if (currentFocusIndex >= 0) {
                executeCurrentItem();
            } else if (filteredApplications.length > 0) {
                Quickshell.execDetached(["bash", "-c", filteredApplications[0].execString]);
                text = "";
                root.showing = false;
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            navigateGrid("down");
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            navigateGrid("up");
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            navigateGrid("left");
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            navigateGrid("right");
            event.accepted = true;
        }
    }

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

    Rectangle {
        id: searchBar

        implicitHeight: textInput.implicitHeight + 30

        color: Colors.bgDim
        radius: Styles.radius0

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        readonly property int textSize: 25

        TextInput {
            id: textInput

            font.pixelSize: searchBar.textSize
            color: Colors.fg
            focus: true
            selectByMouse: true
            cursorVisible: true
            verticalAlignment: TextInput.AlignVCenter

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: parent.right
                leftMargin: Styles.margin
                rightMargin: Styles.margin
            }

            onTextChanged: root.updateFilteredApplications()

            Keys.onPressed: root.gridNavigationController(event)
        }

        TextStyled {
            anchors.left: textInput.left
            anchors.verticalCenter: textInput.verticalCenter
            text: "Search"
            opacity: 0.4
            visible: textInput.text === ""
        }
    }

    GridView {
        id: appGridView

        width: parent.width + Styles.margin
        clip: true

        cellWidth: width / 3
        cellHeight: 60
        snapMode: GridView.SnapToRow

        anchors {
            top: searchBar.bottom
            bottom: parent.bottom
            topMargin: Styles.margin
        }

        model: filteredApplications
        delegate: ButtonStyled {
            id: menuButton

            implicitWidth: appGridView.cellWidth - Styles.margin
            implicitHeight: appGridView.cellHeight - Styles.margin

            radius: Styles.radiusSm

            isFocused: index === currentFocusIndex

            onClicked: {
                Quickshell.execDetached(["bash", "-c", modelData.execString]);
                textInput.text = "";
                root.showing = false;
            }

            Row {
                id: menuContent
                anchors.fill: parent
                anchors.margins: Styles.margin
                spacing: 10

                IconImage {
                    id: appIcon
                    implicitWidth: 32
                    implicitHeight: 32
                    source: Quickshell.iconPath(modelData.icon)
                }

                TextStyled {
                    id: appName
                    text: modelData.name
                    anchors.left: appIcon.right
                    anchors.margins: Styles.margin
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
}
