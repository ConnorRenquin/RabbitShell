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

    property var displays: HyprctlMonitors.monitors
    property double viewScale: 0.1
    property var selectedDisplay: null

    Component.onCompleted: HyprctlMonitors.loadMonitors()

    onDisplaysChanged: {
        if (displays.length > 0 && selectedDisplay === null)
            selectedDisplay = displays[0];
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
                    onClicked: HyprctlMonitors.applyAllMonitors(root.displays)
                }

                ButtonStyled {
                    id: saveButton
                    text: "Save Config"
                    onClicked: HyprctlMonitors.saveConfiguration(root.displays)
                }

                Item {
                    Layout.preferredWidth: Styles.marginSm
                }

                ButtonStyled {
                    id: reloadButton
                    text: "Reload"
                    onClicked: HyprctlMonitors.loadMonitors()
                }
            }
        }

        RowLayout {
            id: mainContent

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Styles.marginSm

            Rectangle {
                id: displayPlacer
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colors.backgroundLifted
                radius: Styles.radiusSm

                Item {
                    id: displayCanvas

                    clip: true

                    anchors.fill: parent
                    anchors.margins: Styles.marginSm

                    TextStyled {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: Styles.marginSm
                        text: `Displays ${root.displays.length}`
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
                            width: parseInt(modelData.resolution.split('x')[0]) * root.viewScale
                            height: parseInt(modelData.resolution.split('x')[1]) * root.viewScale
                            color: Colors.background
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
                                id: displayInfoTag
                                anchors.centerIn: parent
                                implicitWidth: displayInfo.width + Styles.marginSm
                                implicitHeight: displayInfo.height + Styles.marginSm
                                color: Colors.background
                                radius: Styles.radiusSm
                                Column {
                                    id: displayInfo
                                    anchors.centerIn: parent
                                    spacing: Styles.marginSm
                                    TextStyled {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: thing.modelData.name
                                    }
                                    TextStyled {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: thing.modelData.resolution
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    id: zoomButtons
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Styles.marginMd
                    spacing: Styles.marginSm

                    ButtonStyled {
                        text: "-"
                        onClicked: {
                            if (root.viewScale > 0.05)
                                root.viewScale -= 0.05;
                        }
                    }

                    TextStyled {
                        text: `${Math.round(root.viewScale * 1000)}%`
                    }

                    ButtonStyled {
                        text: "+"
                        onClicked: {
                            if (root.viewScale < 0.5)
                                root.viewScale += 0.05;
                        }
                    }
                }
            }

            Rectangle {
                id: rightPanel
                Layout.preferredWidth: 340
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
                            id: leftPanelTitle
                            text: "Displays"
                            font.bold: true
                        }

                        GridLayoutPlus {
                            id: displaysList

                            Layout.fillWidth: true
                            Layout.preferredHeight: 150

                            model: root.displays

                            delegate: Rectangle {
                                id: displayInfoCard

                                required property var modelData

                                Layout.fillWidth: true
                                Layout.preferredHeight: 40

                                color: root.selectedDisplay === modelData ? Colors.background : Colors.backgroundLifted
                                radius: Styles.radiusSm

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Styles.marginSm
                                    spacing: Styles.marginSm

                                    Rectangle {
                                        Layout.preferredWidth: 12
                                        Layout.preferredHeight: 12
                                        radius: Styles.radiusSm
                                        color: displayInfoCard.modelData.enabled ? Colors.success : Colors.error
                                    }

                                    TextStyled {
                                        text: displayInfoCard.modelData.name
                                        font.bold: root.selectedDisplay === displayInfoCard.modelData
                                        Layout.fillWidth: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.selectedDisplay = displayInfoCard.modelData
                                }
                            }
                        }

                        TextStyled {
                            text: root.selectedDisplay ? `${root.selectedDisplay.name} - ${root.selectedDisplay.description}` : ""
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Enabled:"
                                Layout.preferredWidth: 120
                            }

                            SwitchStyled {
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
                                text: "Primary Display"
                            }

                            SwitchStyled {
                                checked: root.selectedDisplay ? root.selectedDisplay.isPrimary : false
                                enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false

                                onToggled: {
                                    if (root.selectedDisplay && root.selectedDisplay.enabled) {
                                        for (var i = 0; i < root.displays.length; i++) {
                                            if (root.displays[i].isPrimary)
                                                root.displays[i].isPrimary = false;
                                        }

                                        for (var i = 0; i < root.displays.length; i++) {
                                            if (root.displays[i] === root.selectedDisplay) {
                                                root.displays[i].isPrimary = true;
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

                            ComboBoxStyled {
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
                                        for (var i = 0; i < root.displays.length; i++) {
                                            if (root.displays[i] === root.selectedDisplay) {
                                                root.displays[i].resolution = currentText;
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
                                text: "Refresh Rate"
                            }

                            ComboBoxStyled {
                                enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                Layout.fillWidth: true
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
                                        for (var i = 0; i < root.displays.length; i++) {
                                            if (root.displays[i] === root.selectedDisplay) {
                                                root.displays[i].refreshRate = parseInt(currentText);
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
                                text: "Scale"
                            }

                            ComboBoxStyled {
                                enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                Layout.fillWidth: true
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
                                        for (var i = 0; i < root.displays.length; i++) {
                                            if (root.displays[i] === root.selectedDisplay) {
                                                root.displays[i].scale = parseFloat(currentText);
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

                            ComboBoxStyled {
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
                                        for (var i = 0; i < root.displays.length; i++) {
                                            if (root.displays[i] === root.selectedDisplay) {
                                                root.displays[i].rotation = currentValue;
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
                                text: "Position"
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                TextStyled {
                                    text: "X"
                                }

                                TextFieldStyled {
                                    enabled: root.selectedDisplay ? root.selectedDisplay.enabled : false
                                    text: root.selectedDisplay ? root.selectedDisplay.position.x : ""
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    validator: IntValidator {}

                                    onTextChanged: {
                                        if (root.selectedDisplay && text) {
                                            for (var i = 0; i < root.displays.length; i++) {
                                                if (root.displays[i] === root.selectedDisplay) {
                                                    root.displays[i].position.x = parseInt(text);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }

                                TextStyled {
                                    text: "Y"
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
