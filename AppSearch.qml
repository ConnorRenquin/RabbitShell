import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick

import qs.Constants
import qs.Components
import qs.Services

PanelWindow {
    id: root

    implicitWidth: 1000
    implicitHeight: 345
    focusable: true
    color: "transparent"
    visible: false

    Component.onCompleted: updateFilteredApplications()

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

    function reset() {
        textInput.text = "";
        root.visible = false;
    }

    function gridNavigationController(event) {
        if ([Qt.Key_Escape].includes(event.key)) {
            reset();
        } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
            appGridView.currentItem.clicked(null);
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

    GlobalShortcut {
        name: "appsearch"
        onPressed: {
            root.visible = !root.visible;
            grab.active = !root.visible;
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        onCleared: root.visible = false
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

    Rectangle {
        color: Colors.bgDim
        radius: Styles.radiusSm
        implicitWidth: parent.width

        anchors {
            top: searchBar.bottom
            bottom: parent.bottom
            margins: Styles.marginSm
        }

        TextStyled {
            anchors.centerIn: parent
            visible: root.filteredApplications.length === 0
            text: "No results found."
        }

        GridView {
            id: appGridView

            clip: true
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            anchors.centerIn: parent

            cellWidth: width / 3
            cellHeight: 60
            snapMode: GridView.SnapToRow

            model: filteredApplications
            delegate: ButtonStyled {
                id: menuButton

                implicitWidth: appGridView.cellWidth - Styles.margin
                implicitHeight: appGridView.cellHeight - Styles.margin

                radius: Styles.radiusSm

                isFocused: index === appGridView.currentIndex

                onClicked: {
                    Quickshell.execDetached(["bash", "-c", modelData.execString]);
                    textInput.text = "";
                    root.visible = false;
                }

                IconImage {
                    id: appIcon
                    implicitWidth: 32
                    implicitHeight: 32
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: Styles.marginSm
                    source: Quickshell.iconPath(modelData.icon) ?? ""
                }

                TextStyled {
                    id: appName
                    anchors.left: appIcon.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Styles.marginSm
                    anchors.right: parent.right
                    text: modelData.name
                    elide: Text.ElideRight
                }
            }
        }
    }
}
