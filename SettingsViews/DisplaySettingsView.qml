pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components
import qs.Services

Rectangle {
    id: root

    anchors.fill: parent
    color: Colors.backgroundLifted

    property var displays: HyprlandMonitors.monitors
    property var workspaces: generateWorkspaces()
    property int numWorkspaces: 10
    property double viewScale: 0.2
    property var selectedDisplay: null

    function generateWorkspaces() {
        var ws = [];
        var enabledMonitors = displays.filter(m => m.enabled && !m.disabled);

        if (enabledMonitors.length === 0)
            return ws;

        var workspacesPerMonitor = Math.ceil(numWorkspaces / enabledMonitors.length);

        for (var i = 1; i <= numWorkspaces; i++) {
            var monitorIndex = Math.floor((i - 1) / workspacesPerMonitor);
            if (monitorIndex >= enabledMonitors.length)
                monitorIndex = enabledMonitors.length - 1;

            ws.push({
                id: i,
                output: enabledMonitors[monitorIndex].name
            });
        }

        return ws;
    }

    function applySettings() {
        console.log("Applying display settings");
        HyprlandMonitors.applyAllMonitors(displays);
    }

    function saveSettings() {
        console.log("Saving display settings to config files");

        var monitorConfigPath = "~/.config/hypr/monitors.conf";
        var workspaceConfigPath = "~/.config/hypr/workspaces.conf";

        HyprlandMonitors.saveConfiguration(displays, monitorConfigPath);
        HyprlandMonitors.saveWorkspaceConfig(workspaces, workspaceConfigPath);

        console.log("Configuration saved!");
    }

    function identifyDisplay(displayName) {
        console.log(`Identifying display: ${displayName}`);
    }

    Component.onCompleted: {
        HyprlandMonitors.loadMonitors();
    }

    onDisplaysChanged: {
        if (displays.length > 0 && selectedDisplay === null)
            selectedDisplay = displays[0];

        workspaces = generateWorkspaces();
    }

    ColumnLayout {
        id: rootLayout

        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        Rectangle {
            id: viewToolbar

            Layout.fillWidth: true
            Layout.preferredHeight: applyButton.implicitHeight + Styles.marginSm * 2

            color: Colors.background
            radius: Styles.radiusSm

            RowLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                TextStyled {
                    id: viewTitle
                    text: "Display Settings"
                    font.bold: true
                }

                Item {
                    id: toolbarSpacer
                    Layout.fillWidth: true
                }

                ButtonStyled {
                    id: applyButton
                    text: "Apply"
                    onClicked: root.applySettings()
                }

                ButtonStyled {
                    id: saveButton
                    text: "Save Config"
                    onClicked: root.saveSettings()
                }

                Item {
                    Layout.preferredWidth: Styles.marginSm
                }

                ButtonStyled {
                    id: reloadButton
                    text: "Reload"
                    onClicked: HyprlandMonitors.loadMonitors()
                }
            }
        }

        RowLayout {
            id: mainContent

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Styles.marginSm

            Rectangle {
                id: leftPanel

                Layout.preferredWidth: 350
                Layout.fillHeight: true

                color: Colors.background
                radius: Styles.radiusSm

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm

                    TextStyled {
                        id: leftPanelTitle
                        text: "Displays"
                        font.bold: true
                    }

                    ListView {
                        id: displaysList

                        Layout.fillWidth: true
                        Layout.preferredHeight: 150

                        model: root.displays

                        delegate: Rectangle {
                            id: displayInfoCard

                            required property var modelData

                            width: displaysList.width
                            height: 40

                            color: root.selectedDisplay === modelData ? Colors.background : Colors.backgroundLifted
                            radius: Styles.radiusSm

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 5

                                Rectangle {
                                    Layout.preferredWidth: 12
                                    Layout.preferredHeight: 12
                                    radius: 6
                                    color: displayInfoCard.modelData.enabled ? Colors.success : Colors.error
                                }

                                TextStyled {
                                    text: displayInfoCard.modelData.name
                                    font.bold: root.selectedDisplay === displayInfoCard.modelData
                                    Layout.fillWidth: true
                                }

                                ButtonStyled {
                                    text: "ID"
                                    Layout.preferredWidth: 35
                                    Layout.preferredHeight: 25
                                    onClicked: root.identifyDisplay(displayInfoCard.modelData.name)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectedDisplay = displayInfoCard.modelData
                            }
                        }
                    }

                    TextStyled {
                        id: workspacesTitle
                        text: "Workspace Assignments"
                        font.bold: true
                    }

                    ListView {
                        id: workspaceList

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Styles.marginSm

                        model: root.workspaces
                        delegate: Rectangle {
                            id: workspaceCard

                            required property var modelData
                            required property var index

                            width: workspaceList.width
                            height: 40
                            color: Colors.backgroundLifted
                            radius: Styles.radiusSm

                            RowLayout {
                                anchors.fill: parent
                                spacing: Styles.marginSm

                                TextStyled {
                                    text: workspaceCard.modelData.id
                                    Layout.margins: Styles.marginSm
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                ComboBox {
                                    id: outputComboBox

                                    Layout.margins: Styles.marginSm

                                    model: {
                                        var enabledDisplays = [];
                                        for (var i = 0; i < root.displays.length; i++) {
                                            if (root.displays[i].enabled)
                                                enabledDisplays.push(root.displays[i].name);
                                        }
                                        return enabledDisplays;
                                    }

                                    Component.onCompleted: {
                                        var index = -1;
                                        for (var i = 0; i < model.length; i++) {
                                            if (model[i] === workspaceCard.modelData.output) {
                                                index = i;
                                                break;
                                            }
                                        }
                                        if (index >= 0)
                                            currentIndex = index;
                                    }

                                    onCurrentTextChanged: {
                                        if (currentText)
                                            root.workspaces[workspaceCard.index].output = currentText;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Center panel - Visual display preview
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colors.backgroundLifted
                radius: Styles.radiusSm
                border.color: Colors.background
                border.width: 2

                Canvas {
                    id: gridCanvas

                    anchors.fill: parent

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = Qt.alpha(Colors.foreground, 0.1);
                        ctx.lineWidth = 1;

                        for (var x = 50; x < width; x += 50) {
                            ctx.beginPath();
                            ctx.moveTo(x, 0);
                            ctx.lineTo(x, height);
                            ctx.stroke();
                        }

                        for (var y = 50; y < height; y += 50) {
                            ctx.beginPath();
                            ctx.moveTo(0, y);
                            ctx.lineTo(width, y);
                            ctx.stroke();
                        }
                    }
                }

                Item {
                    id: displayCanvas

                    anchors.fill: parent
                    anchors.margins: Styles.marginSm

                    TextStyled {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 10
                        text: `Displays: ${root.displays.length} | Scale: ${Math.round(root.viewScale * 100)}%`
                        font.pixelSize: 10
                        color: Qt.alpha(Colors.foreground, 0.5)
                    }

                    TextStyled {
                        anchors.centerIn: parent
                        visible: root.displays.length === 0
                        text: "No displays detected\nClick 'Reload' to refresh"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Repeater {
                        model: root.displays

                        delegate: Rectangle {
                            id: thing

                            required property var modelData

                            visible: modelData.enabled && !modelData.disabled
                            x: modelData.position.x * root.viewScale + displayCanvas.width / 2 - width / 2
                            y: modelData.position.y * root.viewScale + displayCanvas.height / 2 - height / 2
                            width: Math.max(50, parseInt(modelData.resolution.split('x')[0]) * root.viewScale)
                            height: Math.max(30, parseInt(modelData.resolution.split('x')[1]) * root.viewScale)
                            color: root.selectedDisplay === modelData ? Qt.alpha(Colors.primary, 0.3) : Colors.background
                            border.color: root.selectedDisplay === modelData ? Colors.primary : Colors.foreground
                            border.width: 2
                            radius: Styles.radiusSm

                            MouseArea {
                                anchors.fill: parent
                                drag.target: parent
                                drag.axis: Drag.XAxis | Drag.YAxis
                                cursorShape: Qt.OpenHandCursor

                                onClicked: root.selectedDisplay = thing.modelData

                                onPressed: cursorShape = Qt.ClosedHandCursor

                                onReleased: {
                                    cursorShape = Qt.OpenHandCursor;

                                    var newX = Math.round((parent.x - displayCanvas.width / 2 + parent.width / 2) / root.viewScale);
                                    var newY = Math.round((parent.y - displayCanvas.height / 2 + parent.height / 2) / root.viewScale);

                                    var updatedDisplays = root.displays.slice();
                                    for (var i = 0; i < updatedDisplays.length; i++) {
                                        if (updatedDisplays[i].name === thing.modelData.name) {
                                            updatedDisplays[i].position.x = newX;
                                            updatedDisplays[i].position.y = newY;
                                            break;
                                        }
                                    }
                                    root.displays = updatedDisplays;
                                }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: displayInfo.width + 10
                                height: displayInfo.height + 10
                                color: Qt.alpha(Colors.background, 0.9)
                                radius: Styles.radiusSm
                                border.color: Colors.foreground
                                border.width: 1

                                Column {
                                    id: displayInfo

                                    anchors.centerIn: parent
                                    spacing: 2

                                    TextStyled {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: thing.modelData.name
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    TextStyled {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: thing.modelData.resolution
                                        font.pixelSize: 8
                                        color: Qt.alpha(Colors.foreground, 0.7)
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm

                    ButtonStyled {
                        text: "-"
                        implicitWidth: 30
                        implicitHeight: 30
                        onClicked: {
                            if (root.viewScale > 0.05)
                                root.viewScale -= 0.05;
                        }
                    }

                    TextStyled {
                        text: `${Math.round(root.viewScale * 100)}%`
                    }

                    ButtonStyled {
                        text: "+"
                        implicitWidth: 30
                        implicitHeight: 30
                        onClicked: {
                            if (root.viewScale < 0.5)
                                root.viewScale += 0.05;
                        }
                    }
                }
            }

            // Right panel - Display properties
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: Colors.background
                radius: Styles.radiusSm
                visible: root.selectedDisplay !== null

                ScrollView {
                    anchors.fill: parent
                    contentWidth: availableWidth

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        TextStyled {
                            text: root.selectedDisplay ? `${root.selectedDisplay.name} - ${root.selectedDisplay.description}` : ""
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Enabled:"
                                Layout.preferredWidth: 120
                            }

                            Switch {
                                Layout.preferredHeight: 30
                                checked: root.selectedDisplay ? root.selectedDisplay.enabled : false

                                onToggled: {
                                    if (root.selectedDisplay) {
                                        for (var i = 0; i < root.displays.length; i++) {
                                            if (root.displays[i] === root.selectedDisplay) {
                                                root.displays[i].enabled = checked;

                                                if (!checked && root.displays[i].isPrimary) {
                                                    root.displays[i].isPrimary = false;
                                                    for (var j = 0; j < root.displays.length; j++) {
                                                        if (root.displays[j].enabled && j !== i) {
                                                            root.displays[j].isPrimary = true;
                                                            break;
                                                        }
                                                    }
                                                }
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Primary Display:"
                                Layout.preferredWidth: 120
                            }

                            Switch {
                                Layout.preferredHeight: 30
                                checked: root.selectedDisplay ? root.selectedDisplay.isPrimary : false
                                enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false

                                onToggled: {
                                    if (root.selectedDisplay && root.selectedDisplay.enabled) {
                                        for (var i = 0; i < displays.length; i++) {
                                            if (displays[i].isPrimary)
                                                displays[i].isPrimary = false;
                                        }

                                        for (var i = 0; i < displays.length; i++) {
                                            if (displays[i] === root.selectedDisplay) {
                                                displays[i].isPrimary = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Resolution:"
                                Layout.preferredWidth: 120
                            }

                            ComboBox {
                                enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30

                                model: {
                                    if (root.selectedDisplay) {
                                        var resolutions = [];
                                        root.selectedDisplay.modes.forEach(function (mode) {
                                            if (!resolutions.includes(mode.resolution))
                                                resolutions.push(mode.resolution);
                                        });
                                        return resolutions;
                                    }
                                    return [];
                                }

                                Component.onCompleted: {
                                    if (root.selectedDisplay) {
                                        var index = -1;
                                        for (var i = 0; i < model.length; i++) {
                                            if (model[i] === root.selectedDisplay.resolution) {
                                                index = i;
                                                break;
                                            }
                                        }
                                        if (index >= 0)
                                            currentIndex = index;
                                    }
                                }

                                onCurrentTextChanged: {
                                    if (root.selectedDisplay && currentText) {
                                        for (var i = 0; i < displays.length; i++) {
                                            if (displays[i] === root.selectedDisplay) {
                                                displays[i].resolution = currentText;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Refresh Rate:"
                                Layout.preferredWidth: 120
                            }

                            ComboBox {
                                enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30

                                model: {
                                    if (root.selectedDisplay) {
                                        var rates = [];
                                        root.selectedDisplay.modes.forEach(function (mode) {
                                            if (mode.resolution === root.selectedDisplay.resolution && !rates.includes(mode.refreshRate))
                                                rates.push(mode.refreshRate);
                                        });
                                        return rates;
                                    }
                                    return [];
                                }

                                Component.onCompleted: {
                                    if (root.selectedDisplay) {
                                        var index = -1;
                                        for (var i = 0; i < model.length; i++) {
                                            if (model[i] === root.selectedDisplay.refreshRate) {
                                                index = i;
                                                break;
                                            }
                                        }
                                        if (index >= 0)
                                            currentIndex = index;
                                    }
                                }

                                onCurrentTextChanged: {
                                    if (root.selectedDisplay && currentText) {
                                        for (var i = 0; i < displays.length; i++) {
                                            if (displays[i] === root.selectedDisplay) {
                                                displays[i].refreshRate = parseInt(currentText);
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Scale:"
                                Layout.preferredWidth: 120
                            }

                            ComboBox {
                                enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                model: ["0.5", "0.75", "1.0", "1.25", "1.5", "2.0"]

                                Component.onCompleted: {
                                    if (root.selectedDisplay) {
                                        var scaleStr = root.selectedDisplay.scale.toString();
                                        var index = -1;
                                        for (var i = 0; i < model.length; i++) {
                                            if (model[i] === scaleStr) {
                                                index = i;
                                                break;
                                            }
                                        }
                                        if (index >= 0) {
                                            currentIndex = index;
                                        } else {
                                            for (var i = 0; i < model.length; i++) {
                                                if (model[i] === "1.0") {
                                                    currentIndex = i;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }

                                onCurrentTextChanged: {
                                    if (root.selectedDisplay && currentText) {
                                        for (var i = 0; i < displays.length; i++) {
                                            if (displays[i] === root.selectedDisplay) {
                                                displays[i].scale = parseFloat(currentText);
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Rotation:"
                                Layout.preferredWidth: 120
                            }

                            ComboBox {
                                enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30

                                model: [
                                    {
                                        text: "Normal",
                                        value: 0
                                    },
                                    {
                                        text: "90 Degrees Right",
                                        value: 90
                                    },
                                    {
                                        text: "180 Degrees Inverted",
                                        value: 180
                                    },
                                    {
                                        text: "90 Degrees Left",
                                        value: 270
                                    }
                                ]
                                textRole: "text"
                                valueRole: "value"

                                Component.onCompleted: {
                                    if (root.selectedDisplay) {
                                        var index = -1;
                                        for (var i = 0; i < model.length; i++) {
                                            if (model[i].value === root.selectedDisplay.rotation) {
                                                index = i;
                                                break;
                                            }
                                        }
                                        if (index >= 0)
                                            currentIndex = index;
                                    }
                                }

                                onCurrentValueChanged: {
                                    if (root.selectedDisplay) {
                                        for (var i = 0; i < displays.length; i++) {
                                            if (displays[i] === root.selectedDisplay) {
                                                displays[i].rotation = currentValue;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Styles.marginSm

                            TextStyled {
                                text: "Position:"
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                TextStyled {
                                    text: "X:"
                                    Layout.preferredWidth: 30
                                }

                                TextFieldStyled {
                                    enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                    text: root.selectedDisplay ? root.selectedDisplay.position.x : ""
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    validator: IntValidator {}

                                    onTextChanged: {
                                        if (selectedDisplay && text) {
                                            for (var i = 0; i < root.displays.length; i++) {
                                                if (root.displays[i] === selectedDisplay) {
                                                    root.displays[i].position.x = parseInt(text);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }

                                TextStyled {
                                    text: "Y:"
                                    Layout.preferredWidth: 30
                                }

                                TextFieldStyled {
                                    enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                    text: root.selectedDisplay ? root.selectedDisplay.position.y : ""
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    validator: IntValidator {}

                                    onTextChanged: {
                                        if (root.selectedDisplay && text) {
                                            for (var i = 0; i < root.displays.length; i++) {
                                                if (root.displays[i] === root.selectedDisplay) {
                                                    root.displays[i].position.y = parseInt(text);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }
}
