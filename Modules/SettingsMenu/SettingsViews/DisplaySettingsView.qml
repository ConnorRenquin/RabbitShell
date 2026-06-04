pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Modules.SettingsMenu.SettingsViews.Components
import qs.Components
import qs.Components.Plus
import qs.Components.Styled
import qs.Services
import qs.Services.Models

Rectangle {
    id: root

    required property string name

    anchors.fill: parent
    color: Qt.lighter(Colors.surface, Colors.lighter)

    property double viewScale: 0.1
    property var selectedMonitorIndex: 0
    property list<MonitorInfo> monitors: HyprctlMonitors.monitors
    property string statusText: ""
    property bool monitorConfigLoaded: false
    property bool edgeSnapEnabled: true
    property int snapThreshold: 120
    property bool verticalSnapGuideVisible: false
    property bool horizontalSnapGuideVisible: false
    property real verticalSnapGuideX: 0
    property real horizontalSnapGuideY: 0

    function selectedMonitor() {
        return root.monitors[root.selectedMonitorIndex] ?? null;
    }

    function currentModeText(monitor) {
        if (!monitor)
            return "";
        return monitor.width + "x" + monitor.height + "@" + monitor.refreshRate + "Hz";
    }

    function modeIndex(monitor) {
        if (!monitor || !monitor.availableModes)
            return -1;
        var wantedWidth = parseInt(monitor.width);
        var wantedHeight = parseInt(monitor.height);
        var wantedRate = parseFloat(monitor.refreshRate);
        for (var i = 0; i < monitor.availableModes.length; i++) {
            var match = String(monitor.availableModes[i]).match(/(\d+)x(\d+)@([\d.]+)Hz/);
            if (match && parseInt(match[1]) === wantedWidth && parseInt(match[2]) === wantedHeight && Math.abs(parseFloat(match[3]) - wantedRate) < 0.1)
                return i;
        }
        return -1;
    }

    function scaleIndex(monitor) {
        if (!monitor)
            return 2;
        var scales = ["0.5", "0.75", "1.0", "1.25", "1.5", "2.0"];
        var value = Number(monitor.scale).toFixed(1);
        return Math.max(0, scales.indexOf(value));
    }

    function applySavedMonitorSettings() {
        HyprlandSettings.applyMonitorSettingsToList(root.monitors);
        Qt.callLater(root.centerDisplayCanvas);
    }

    function monitorBounds() {
        if (!root.monitors || root.monitors.length === 0)
            return null;
        var hasMonitor = false;
        var minX = 0;
        var minY = 0;
        var maxX = 0;
        var maxY = 0;
        for (var i = 0; i < root.monitors.length; i++) {
            var monitor = root.monitors[i];
            if (!monitor || monitor.disabled)
                continue;
            var x = parseInt(monitor.x);
            var y = parseInt(monitor.y);
            var width = parseInt(monitor.width);
            var height = parseInt(monitor.height);
            if (!hasMonitor) {
                minX = x;
                minY = y;
                maxX = x + width;
                maxY = y + height;
                hasMonitor = true;
            } else {
                minX = Math.min(minX, x);
                minY = Math.min(minY, y);
                maxX = Math.max(maxX, x + width);
                maxY = Math.max(maxY, y + height);
            }
        }
        return hasMonitor ? {
            minX: minX,
            minY: minY,
            maxX: maxX,
            maxY: maxY,
            centerX: (minX + maxX) / 2,
            centerY: (minY + maxY) / 2
        } : null;
    }

    function centerDisplayCanvas() {
        if (!displayCanvas || !displayCanvas.contentItem)
            return;
        var bounds = monitorBounds();
        var logicalCenterX = bounds ? bounds.centerX : 0;
        var logicalCenterY = bounds ? bounds.centerY : 0;
        var contentCenterX = displayCanvas.contentWidth / 2 + logicalCenterX * root.viewScale;
        var contentCenterY = displayCanvas.contentHeight / 2 + logicalCenterY * root.viewScale;
        displayCanvas.contentItem.contentX = Math.max(0, contentCenterX - displayCanvas.width / 2);
        displayCanvas.contentItem.contentY = Math.max(0, contentCenterY - displayCanvas.height / 2);
    }

    function snapValue(value, candidates, threshold) {
        var snapped = value;
        var bestDistance = threshold + 1;
        for (var i = 0; i < candidates.length; i++) {
            var distance = Math.abs(value - candidates[i]);
            if (distance <= threshold && distance < bestDistance) {
                snapped = candidates[i];
                bestDistance = distance;
            }
        }
        return snapped;
    }

    function logicalToContentX(x) {
        return displayCanvas.contentWidth / 2 + x * root.viewScale;
    }

    function logicalToContentY(y) {
        return displayCanvas.contentHeight / 2 + y * root.viewScale;
    }

    function clearSnapGuides() {
        verticalSnapGuideVisible = false;
        horizontalSnapGuideVisible = false;
    }

    function rangesOverlap(startA, endA, startB, endB, margin) {
        return startA <= endB + margin && startB <= endA + margin;
    }

    function monitorsOverlap(x, y, width, height, other) {
        var otherLeft = parseInt(other.x);
        var otherTop = parseInt(other.y);
        var otherRight = otherLeft + parseInt(other.width);
        var otherBottom = otherTop + parseInt(other.height);
        return x < otherRight && x + width > otherLeft && y < otherBottom && y + height > otherTop;
    }

    function snapCandidates(index, x, y) {
        var result = {
            xCandidates: [],
            yCandidates: [],
            xGuides: ({}),
            yGuides: ({})
        };
        var monitor = root.monitors[index];
        if (!root.edgeSnapEnabled || root.monitors.length < 2 || !monitor)
            return result;
        var width = parseInt(monitor.width);
        var height = parseInt(monitor.height);
        for (var i = 0; i < root.monitors.length; i++) {
            if (i === index)
                continue;
            var other = root.monitors[i];
            if (!other || other.disabled)
                continue;
            var otherLeft = parseInt(other.x);
            var otherTop = parseInt(other.y);
            var otherWidth = parseInt(other.width);
            var otherHeight = parseInt(other.height);
            var otherRight = otherLeft + otherWidth;
            var otherBottom = otherTop + otherHeight;
            var otherCenterX = otherLeft + otherWidth / 2;
            var otherCenterY = otherTop + otherHeight / 2;

            if (rangesOverlap(y, y + height, otherTop, otherBottom, root.snapThreshold)) {
                result.xCandidates.push(otherRight);
                result.xGuides[otherRight] = otherRight;
                result.xCandidates.push(otherLeft - width);
                result.xGuides[otherLeft - width] = otherLeft;
                result.xCandidates.push(otherLeft);
                result.xGuides[otherLeft] = otherLeft;
                result.xCandidates.push(otherRight - width);
                result.xGuides[otherRight - width] = otherRight;
                var centerXCandidate = Math.round(otherCenterX - width / 2);
                result.xCandidates.push(centerXCandidate);
                result.xGuides[centerXCandidate] = otherCenterX;
            }
            if (rangesOverlap(x, x + width, otherLeft, otherRight, root.snapThreshold)) {
                result.yCandidates.push(otherBottom);
                result.yGuides[otherBottom] = otherBottom;
                result.yCandidates.push(otherTop - height);
                result.yGuides[otherTop - height] = otherTop;
                result.yCandidates.push(otherTop);
                result.yGuides[otherTop] = otherTop;
                result.yCandidates.push(otherBottom - height);
                result.yGuides[otherBottom - height] = otherBottom;
                var centerYCandidate = Math.round(otherCenterY - height / 2);
                result.yCandidates.push(centerYCandidate);
                result.yGuides[centerYCandidate] = otherCenterY;
            }
        }
        return result;
    }

    function nearestSnap(value, candidates, guides, threshold) {
        var bestCandidate = null;
        var bestDistance = threshold + 1;
        for (var i = 0; i < candidates.length; i++) {
            var candidate = candidates[i];
            var distance = Math.abs(value - candidate);
            if (distance <= threshold && distance < bestDistance) {
                bestCandidate = candidate;
                bestDistance = distance;
            }
        }
        return bestCandidate === null ? null : {
            value: bestCandidate,
            guide: guides[bestCandidate]
        };
    }

    function updateSnapGuides(index, x, y) {
        var candidates = snapCandidates(index, x, y);
        var xSnap = nearestSnap(x, candidates.xCandidates, candidates.xGuides, root.snapThreshold);
        var ySnap = nearestSnap(y, candidates.yCandidates, candidates.yGuides, root.snapThreshold);
        verticalSnapGuideVisible = xSnap !== null;
        horizontalSnapGuideVisible = ySnap !== null;
        if (xSnap !== null)
            verticalSnapGuideX = logicalToContentX(xSnap.guide);
        if (ySnap !== null)
            horizontalSnapGuideY = logicalToContentY(ySnap.guide);
    }

    function snappedMonitorPosition(index, x, y) {
        if (!root.edgeSnapEnabled || root.monitors.length < 2)
            return {
                x: x,
                y: y
            };
        var monitor = root.monitors[index];
        if (!monitor)
            return {
                x: x,
                y: y
            };
        var width = parseInt(monitor.width);
        var height = parseInt(monitor.height);
        var snappedX = x;
        var snappedY = y;
        var candidates = snapCandidates(index, x, y);
        snappedX = snapValue(snappedX, candidates.xCandidates, root.snapThreshold);
        snappedY = snapValue(snappedY, candidates.yCandidates, root.snapThreshold);

        for (var pass = 0; pass < 4; pass++) {
            var changed = false;
            for (var j = 0; j < root.monitors.length; j++) {
                if (j === index)
                    continue;
                var overlapOther = root.monitors[j];
                if (!overlapOther || overlapOther.disabled || !monitorsOverlap(snappedX, snappedY, width, height, overlapOther))
                    continue;

                var left = parseInt(overlapOther.x);
                var top = parseInt(overlapOther.y);
                var right = left + parseInt(overlapOther.width);
                var bottom = top + parseInt(overlapOther.height);
                var moves = [
                    {
                        axis: "x",
                        value: left - width,
                        distance: Math.abs(snappedX - (left - width))
                    },
                    {
                        axis: "x",
                        value: right,
                        distance: Math.abs(snappedX - right)
                    },
                    {
                        axis: "y",
                        value: top - height,
                        distance: Math.abs(snappedY - (top - height))
                    },
                    {
                        axis: "y",
                        value: bottom,
                        distance: Math.abs(snappedY - bottom)
                    }
                ];
                moves.sort(function (a, b) {
                    return a.distance - b.distance;
                });
                if (moves[0].axis === "x")
                    snappedX = moves[0].value;
                else
                    snappedY = moves[0].value;
                changed = true;
            }
            if (!changed)
                break;
        }

        return {
            x: snappedX,
            y: snappedY
        };
    }

    function writeMonitorConfigCommand(path, content) {
        return "mkdir -p \"" + HyprlandSettings.homePath + "/.config/hypr\"\nif [ -f \"" + path + "\" ]; then cp -f \"" + path + "\" \"" + path + ".bak\"; fi\ncat > \"" + path + "\" <<'QSMONITOREOF'\n" + content + "QSMONITOREOF\n";
    }

    Component.onCompleted: {
        HyprctlMonitors.loadMonitors();
        Qt.callLater(root.centerDisplayCanvas);
    }

    Connections {
        target: HyprctlMonitors
        function onMonitorsChanged() {
            if (root.selectedMonitorIndex >= root.monitors.length)
                root.selectedMonitorIndex = Math.max(0, root.monitors.length - 1);
            if (root.monitorConfigLoaded)
                root.applySavedMonitorSettings();
            else
                Qt.callLater(root.centerDisplayCanvas);
        }
    }

    FileView {
        id: monitorConfigFile
        path: HyprlandSettings.monitorConfigUrl
        blockLoading: false

        onLoaded: {
            HyprlandSettings.loadMonitorsFromText(text());
            root.monitorConfigLoaded = true;
            root.applySavedMonitorSettings();
            root.statusText = "Loaded " + HyprlandSettings.monitorConfigPath;
        }

        onLoadFailed: {
            root.monitorConfigLoaded = false;
            HyprlandSettings.monitorItems = [];
            root.statusText = "No existing monitor config found; using live Hyprland state.";
        }
    }

    Process {
        id: writeMonitorConfig
        running: false
        function onExited(exitCode) {
            if (exitCode === 0) {
                monitorConfigFile.setText(root.pendingMonitorConfigContent);
                root.statusText = "Saved " + HyprlandSettings.monitorConfigPath;
            } else {
                root.statusText = "Failed to save " + HyprlandSettings.monitorConfigPath + " (exit code " + exitCode + ")";
            }
        }
    }

    property string pendingMonitorConfigContent: ""

    ConfirmationDialog {
        id: saveDialog
        onVisibleChanged: {
            remainingTime = totalTime;
            hideTimer.restart();
            if (saveDialog.visible) {
                HyprctlMonitors.applyAllMonitors(root.monitors);
            } else {
                hideTimer.stop();
            }
        }

        property int totalTime: 15
        property int remainingTime: totalTime

        title: "Apply new Configuration?"
        body: `Reverting in ${remainingTime} second${remainingTime !== 1 ? "s" : ""}`

        onAccepted: {
            hideTimer.stop();
            root.pendingMonitorConfigContent = HyprlandSettings.generateMonitorConfigContent(root.monitors);
            writeMonitorConfig.command = ["bash", "-c", root.writeMonitorConfigCommand(HyprlandSettings.monitorConfigPath, root.pendingMonitorConfigContent)];
            writeMonitorConfig.running = true;
        }

        onCanceled: Quickshell.execDetached(["bash", "-c", "hyprctl reload"])

        Timer {
            id: hideTimer
            interval: 1000
            repeat: true
            onTriggered: {
                saveDialog.remainingTime--;
                if (saveDialog.remainingTime <= 0) {
                    stop();
                    saveDialog.visible = false;
                    Quickshell.execDetached(["bash", "-c", "hyprctl reload"]);
                }
            }
        }
    }

    ColumnLayout {
        id: rootLayout

        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm
        SettingsViewTitle {
            id: viewTitle
            title: root.name
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
                color: Qt.lighter(Colors.surface, Colors.lighter)
                clip: true

                ScrollView {
                    id: displayCanvas
                    anchors.fill: parent
                    contentWidth: 3000
                    contentHeight: 3000

                    Component.onCompleted: {
                        if (contentItem && contentItem.interactive !== undefined)
                            contentItem.interactive = false;
                    }

                    MouseArea {
                        id: canvasDragArea
                        width: displayCanvas.contentWidth
                        height: displayCanvas.contentHeight
                        acceptedButtons: Qt.LeftButton
                        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                        property real lastViewportX: 0
                        property real lastViewportY: 0

                        function clampContentX(value) {
                            return Math.max(0, Math.min(Math.max(0, displayCanvas.contentWidth - displayCanvas.width), value));
                        }

                        function clampContentY(value) {
                            return Math.max(0, Math.min(Math.max(0, displayCanvas.contentHeight - displayCanvas.height), value));
                        }

                        onPressed: mouse => {
                            var point = canvasDragArea.mapToItem(displayPlacer, mouse.x, mouse.y);
                            lastViewportX = point.x;
                            lastViewportY = point.y;
                        }

                        onPositionChanged: mouse => {
                            if (!pressed || !displayCanvas.contentItem)
                                return;
                            var point = canvasDragArea.mapToItem(displayPlacer, mouse.x, mouse.y);
                            var deltaX = point.x - lastViewportX;
                            var deltaY = point.y - lastViewportY;
                            displayCanvas.contentItem.contentX = clampContentX(displayCanvas.contentItem.contentX - deltaX);
                            displayCanvas.contentItem.contentY = clampContentY(displayCanvas.contentItem.contentY - deltaY);
                            lastViewportX = point.x;
                            lastViewportY = point.y;
                        }
                    }

                    Rectangle {
                        z: 50
                        visible: root.verticalSnapGuideVisible
                        x: Math.round(root.verticalSnapGuideX) - 1
                        y: 0
                        width: 2
                        height: displayCanvas.contentHeight
                        color: Colors.primary
                        opacity: 0.85
                    }

                    Rectangle {
                        z: 50
                        visible: root.horizontalSnapGuideVisible
                        x: 0
                        y: Math.round(root.horizontalSnapGuideY) - 1
                        width: displayCanvas.contentWidth
                        height: 2
                        color: Colors.primary
                        opacity: 0.85
                    }

                    TextStyled {
                        anchors.centerIn: parent
                        visible: HyprctlMonitors.monitors.length === 0
                        text: "No displays detected\nClick '󰑐' to refresh"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Repeater {
                        model: root.monitors
                        delegate: Rectangle {
                            id: monitorPositionCard

                            required property MonitorInfo modelData
                            required property int index

                            visible: !modelData.disabled
                            readonly property real boundX: Math.ceil(parseInt(modelData.x) * root.viewScale + displayCanvas.contentWidth / 2)
                            readonly property real boundY: Math.ceil(parseInt(modelData.y) * root.viewScale + displayCanvas.contentHeight / 2)
                            property bool isDragging: false
                            x: boundX
                            y: boundY
                            width: parseInt(modelData.width) * root.viewScale
                            height: parseInt(modelData.height) * root.viewScale
                            color: Colors.surface
                            radius: Styles.radiusSm

                            Binding {
                                target: monitorPositionCard
                                property: "x"
                                value: monitorPositionCard.boundX
                                when: !monitorPositionCard.isDragging
                            }

                            Binding {
                                target: monitorPositionCard
                                property: "y"
                                value: monitorPositionCard.boundY
                                when: !monitorPositionCard.isDragging
                            }

                            MouseArea {
                                anchors.fill: parent
                                drag.target: parent
                                drag.axis: Drag.XAxis | Drag.YAxis
                                cursorShape: Qt.OpenHandCursor
                                onPressed: {
                                    monitorPositionCard.isDragging = true;
                                    cursorShape = Qt.ClosedHandCursor;
                                }
                                onClicked: {
                                    root.selectedMonitorIndex = monitorPositionCard.index;
                                }
                                onPositionChanged: {
                                    if (!pressed)
                                        return;
                                    var nextX = Math.ceil((parent.x - displayCanvas.contentWidth / 2) / root.viewScale);
                                    var nextY = Math.ceil((parent.y - displayCanvas.contentHeight / 2) / root.viewScale);
                                    root.updateSnapGuides(monitorPositionCard.index, nextX, nextY);
                                }
                                onReleased: {
                                    cursorShape = Qt.OpenHandCursor;
                                    var nextX = Math.ceil((parent.x - displayCanvas.contentWidth / 2) / root.viewScale);
                                    var nextY = Math.ceil((parent.y - displayCanvas.contentHeight / 2) / root.viewScale);
                                    var snapped = root.snappedMonitorPosition(monitorPositionCard.index, nextX, nextY);
                                    monitorPositionCard.modelData.x = snapped.x;
                                    monitorPositionCard.modelData.y = snapped.y;
                                    monitorPositionCard.isDragging = false;
                                    root.clearSnapGuides();
                                }
                                onCanceled: {
                                    monitorPositionCard.isDragging = false;
                                    root.clearSnapGuides();
                                }
                            }

                            Rectangle {
                                id: displayInfoTag
                                anchors.centerIn: parent
                                implicitWidth: displayInfo.width + Styles.marginSm
                                implicitHeight: displayInfo.height + Styles.marginSm
                                color: Colors.surface
                                radius: Styles.radiusSm
                                Column {
                                    id: displayInfo
                                    anchors.centerIn: parent
                                    spacing: Styles.marginSm
                                    TextStyled {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: monitorPositionCard.modelData.name
                                    }
                                    TextStyled {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: monitorPositionCard.modelData.width + "x" + monitorPositionCard.modelData.height
                                    }
                                }
                            }
                        }
                    }
                }

                TextStyled {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: Styles.marginMd
                    text: root.statusText
                    visible: root.statusText.length > 0
                    font.pointSize: Styles.textSm
                    opacity: 0.75
                }

                RowLayout {
                    id: zoomButtons
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Styles.marginMd
                    spacing: Styles.marginSm

                    ButtonStyled {
                        id: hidePanel
                        text: "󰮫"
                        onClicked: rightPanel.visible = !rightPanel.visible
                    }

                    ButtonStyled {
                        text: "󰊠"
                        onClicked: root.centerDisplayCanvas()
                    }

                    ButtonStyled {
                        text: "-"
                        onClicked: {
                            if (root.viewScale > 0.05) {
                                root.viewScale -= 0.05;
                                Qt.callLater(root.centerDisplayCanvas);
                            }
                        }
                    }

                    TextStyled {
                        text: `${Math.round(root.viewScale * 1000)}%`
                    }

                    ButtonStyled {
                        text: "+"
                        onClicked: {
                            if (root.viewScale < 0.5) {
                                root.viewScale += 0.05;
                                Qt.callLater(root.centerDisplayCanvas);
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: rightPanel
                Layout.preferredWidth: 340
                Layout.fillHeight: true
                color: Colors.surface
                radius: Styles.radiusSm

                ScrollView {
                    anchors.fill: parent
                    contentWidth: availableWidth

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        RowLayout {
                            Layout.fillWidth: true

                            TextStyled {
                                id: leftPanelTitle
                                Layout.fillWidth: true
                                text: "Displays"
                            }

                            TextStyled {
                                text: "Snap"
                                visible: root.monitors.length > 1
                                font.pointSize: Styles.textSm
                            }

                            SwitchStyled {
                                visible: root.monitors.length > 1
                                checked: root.edgeSnapEnabled
                                onToggled: root.edgeSnapEnabled = checked
                            }
                        }

                        GridLayoutPlus {
                            id: displaysList
                            Layout.fillWidth: true
                            model: HyprctlMonitors.monitors
                            delegate: ButtonStyled {
                                id: displayInfoCard
                                required property var modelData
                                required property int index
                                defaultColor: Qt.lighter(Colors.surface, Colors.lighter)
                                onClicked: {
                                    root.selectedMonitorIndex = index;
                                }
                                text: displayInfoCard.modelData.name
                            }
                        }

                        TextStyled {
                            text: root.monitors[root.selectedMonitorIndex] ? `${root.monitors[root.selectedMonitorIndex].name} - ${root.monitors[root.selectedMonitorIndex].description}` : ""
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            TextStyled {
                                text: "Enabled"
                            }
                            SwitchStyled {
                                checked: !root.monitors[root.selectedMonitorIndex]?.disabled ?? false
                                onToggled: root.monitors[root.selectedMonitorIndex].disabled = !checked
                            }
                        }

                        TextStyled {
                            text: "Resolution"
                        }
                        RowLayout {
                            TextFieldStyled {
                                id: widthField
                                Layout.fillWidth: true
                                text: root.monitors[root.selectedMonitorIndex]?.width ?? "1920"
                            }
                            TextFieldStyled {
                                id: heightField
                                Layout.fillWidth: true
                                text: root.monitors[root.selectedMonitorIndex]?.height ?? "1080"
                            }
                            TextFieldStyled {
                                id: refreshRateField
                                Layout.fillWidth: true
                                text: root.monitors[root.selectedMonitorIndex]?.refreshRate ?? "60"
                            }
                            ButtonStyled {
                                text: ""
                                onClicked: {
                                    root.monitors[root.selectedMonitorIndex].width = parseInt(widthField.text);
                                    root.monitors[root.selectedMonitorIndex].height = parseInt(heightField.text);
                                    root.monitors[root.selectedMonitorIndex].refreshRate = parseFloat(refreshRateField.text);
                                }
                            }
                        }

                        RowLayout {
                            id: availableModes

                            property int resolutionWidth
                            property int resolutionHeight
                            property real refreshRate

                            ComboBoxStyled {
                                id: modesBox
                                Layout.fillWidth: true
                                model: root.selectedMonitor()?.availableModes ?? []
                                currentIndex: root.modeIndex(root.selectedMonitor())
                            }

                            ButtonStyled {
                                text: ""
                                onClicked: setMode(modesBox.currentText)
                                function setMode(mode) {
                                    var match = mode.match(/(\d+)x(\d+)@([\d.]+)Hz/);
                                    if (match) {
                                        root.monitors[root.selectedMonitorIndex].width = parseInt(match[1]);
                                        root.monitors[root.selectedMonitorIndex].height = parseInt(match[2]);
                                        root.monitors[root.selectedMonitorIndex].refreshRate = Math.round(parseFloat(match[3]));
                                    }
                                }
                            }
                        }

                        RowLayout {
                            id: monitorScale
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Scale"
                            }

                            ComboBoxStyled {
                                Layout.fillWidth: true
                                model: ["0.5", "0.75", "1.0", "1.25", "1.5", "2.0"]
                                currentIndex: root.scaleIndex(root.selectedMonitor())
                                onActivated: index => {
                                    if (root.selectedMonitor()) {
                                        root.selectedMonitor().scale = parseFloat(model[index] || 1.0);
                                    }
                                }
                            }
                        }

                        RowLayout {
                            id: monitorRotation
                            Layout.fillWidth: true
                            TextStyled {
                                text: "Rotation"
                            }

                            ComboBoxStyled {
                                Layout.fillWidth: true
                                model: ["Normal", "90", "180", "270", "flipped", "flipped + 90", "flipped + 180", "flipped + 270"]
                                currentIndex: root.selectedMonitor()?.transform ?? 0
                                onActivated: index => {
                                    if (root.selectedMonitor()) {
                                        root.selectedMonitor().transform = index ?? 0;
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            id: monitorPosition

                            TextStyled {
                                text: "Position"
                            }

                            RowLayout {
                                TextStyled {
                                    text: "X"
                                }
                                TextFieldStyled {
                                    id: xPosTextField
                                    text: root.monitors[root.selectedMonitorIndex]?.x ?? ""
                                    Layout.fillWidth: true
                                    validator: IntValidator {}
                                    onEditingFinished: {
                                        if (root.monitors[root.selectedMonitorIndex] && text !== "") {
                                            root.monitors[root.selectedMonitorIndex].x = parseInt(text);
                                        }
                                    }
                                }

                                TextStyled {
                                    text: "Y"
                                }

                                TextFieldStyled {
                                    id: yPosTextField
                                    text: root.monitors[root.selectedMonitorIndex]?.y ?? ""
                                    Layout.fillWidth: true
                                    validator: IntValidator {}
                                    onEditingFinished: {
                                        if (root.monitors[root.selectedMonitorIndex] && text !== "") {
                                            root.monitors[root.selectedMonitorIndex].y = parseInt(text);
                                        }
                                    }
                                }

                                ButtonStyled {
                                    text: "zero"
                                    onClicked: {
                                        root.monitors[root.selectedMonitorIndex].y = 0;
                                        root.monitors[root.selectedMonitorIndex].x = 0;
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        RowLayout {
                            ButtonStyled {
                                id: saveButton
                                text: Icons.save
                                onClicked: saveDialog.visible = true
                                Layout.fillWidth: true
                            }

                            ButtonStyled {
                                id: reloadButton
                                Layout.fillWidth: true
                                text: Icons.reset
                                onClicked: {
                                    monitorConfigFile.reload();
                                    HyprctlMonitors.loadMonitors();
                                    Quickshell.execDetached(["bash", "-c", "hyprctl reload"]);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
