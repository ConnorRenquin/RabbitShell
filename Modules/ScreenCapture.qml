

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Helpers
import qs.Components.Styled
import qs.Services

Loader {
    id: loader

    active: false

    property string captureMode: "copysave"
    property string targetMode: "area"
    property string drawingTool: "select"
    property string paintColorMode: "error"
    readonly property color paintColor: paintColorMode === "primary" ? Colors.primary
        : paintColorMode === "tertiary" ? Colors.tertiary
        : paintColorMode === "onSurface" ? Colors.onSurface
        : Colors.error
    property int paintWidth: 6
    property int screenshotDelay: 0
    property int countdownRemaining: 0
    property bool countdownActive: false
    property bool recording: false
    property string recordingPath: ""
    readonly property var screenshotDelays: [0, 3, 5, 10]
    property var shapes: []
    property var currentShape: null
    property bool chromeVisible: true
    property point dragStart: Qt.point(0, 0)
    property rect selection: Qt.rect(0, 0, 0, 0)
    property rect adjustmentStart: Qt.rect(0, 0, 0, 0)
    property string adjustmentMode: ""
    property bool dragging: false
    property bool confirming: false
    readonly property var adjustmentHandles: [
        { xFactor: 0, yFactor: 0 }, { xFactor: 0.5, yFactor: 0 }, { xFactor: 1, yFactor: 0 },
        { xFactor: 0, yFactor: 0.5 }, { xFactor: 1, yFactor: 0.5 },
        { xFactor: 0, yFactor: 1 }, { xFactor: 0.5, yFactor: 1 }, { xFactor: 1, yFactor: 1 }
    ]

    function resetSelection() {
        selection = Qt.rect(0, 0, 0, 0);
        dragging = false;
        adjustmentMode = "";
        countdownTimer.stop();
        countdownRemaining = 0;
        countdownActive = false;
        confirming = false;
        shapes = [];
        currentShape = null;
        chromeVisible = true;
    }

    function updateSetting(name, value) {
        Settings.change({ name: name, value: value });
    }

    function loadSettings() {
        captureMode = Settings.get("screenCaptureMode")?.value ?? "copysave";
        targetMode = Settings.get("screenCaptureTargetMode")?.value ?? "area";
        drawingTool = Settings.get("screenCaptureDrawingTool")?.value ?? "select";
        paintColorMode = Settings.get("screenCapturePaintColor")?.value ?? "error";
        screenshotDelay = Settings.get("screenCaptureDelay")?.value ?? 0;
    }

    function open() {
        resetSelection();
        active = true;
        if (targetMode === "screen") {
            Qt.callLater(() => {
                if (active && item)
                    selectFullScreen(item.width, item.height);
            });
        }
    }

    function close() {
        if (recording) {
            stopRecording();
            return;
        }
        resetSelection();
        active = false;
    }

    function normalizedSelection(start, end) {
        const left = Math.min(start.x, end.x);
        const top = Math.min(start.y, end.y);
        return Qt.rect(left, top, Math.abs(end.x - start.x), Math.abs(end.y - start.y));
    }

    function adjustmentModeAt(x, y) {
        if (!confirming || drawingTool !== "select")
            return "";

        const tolerance = 10;
        const left = Math.abs(x - selection.x) <= tolerance;
        const right = Math.abs(x - selection.x - selection.width) <= tolerance;
        const top = Math.abs(y - selection.y) <= tolerance;
        const bottom = Math.abs(y - selection.y - selection.height) <= tolerance;
        const withinX = x >= selection.x - tolerance && x <= selection.x + selection.width + tolerance;
        const withinY = y >= selection.y - tolerance && y <= selection.y + selection.height + tolerance;

        if (top && left && withinX && withinY) return "topLeft";
        if (top && right && withinX && withinY) return "topRight";
        if (bottom && left && withinX && withinY) return "bottomLeft";
        if (bottom && right && withinX && withinY) return "bottomRight";
        if (top && withinX) return "top";
        if (bottom && withinX) return "bottom";
        if (left && withinY) return "left";
        if (right && withinY) return "right";
        if (x >= selection.x && x <= selection.x + selection.width
                && y >= selection.y && y <= selection.y + selection.height)
            return "move";
        return "";
    }

    function adjustSelection(x, y, surfaceWidth, surfaceHeight) {
        const minimumSize = 2;
        const deltaX = x - dragStart.x;
        const deltaY = y - dragStart.y;
        const start = adjustmentStart;

        if (adjustmentMode === "move") {
            const newX = Math.max(0, Math.min(surfaceWidth - start.width, start.x + deltaX));
            const newY = Math.max(0, Math.min(surfaceHeight - start.height, start.y + deltaY));
            selection = Qt.rect(newX, newY, start.width, start.height);
            return;
        }

        let left = start.x;
        let top = start.y;
        let right = start.x + start.width;
        let bottom = start.y + start.height;
        const mode = adjustmentMode.toLowerCase();
        if (mode.indexOf("left") !== -1)
            left = Math.max(0, Math.min(right - minimumSize, start.x + deltaX));
        if (mode.indexOf("right") !== -1)
            right = Math.min(surfaceWidth, Math.max(left + minimumSize, start.x + start.width + deltaX));
        if (mode.indexOf("top") !== -1)
            top = Math.max(0, Math.min(bottom - minimumSize, start.y + deltaY));
        if (mode.indexOf("bottom") !== -1)
            bottom = Math.min(surfaceHeight, Math.max(top + minimumSize, start.y + start.height + deltaY));
        selection = Qt.rect(left, top, right - left, bottom - top);
    }

    function selectFullScreen(width, height) {
        targetMode = "screen";
        selection = Qt.rect(0, 0, width, height);
        confirming = true;
    }

    function selectWindowAt(localX, localY) {
        const monitor = Hyprland.focusedMonitor;
        const globalX = (monitor?.x ?? 0) + localX;
        const globalY = (monitor?.y ?? 0) + localY;
        for (let index = HyprctlClients.clients.length - 1; index >= 0; index--) {
            const client = HyprctlClients.clients[index];
            if (globalX >= client.at[0] && globalX <= client.at[0] + client.size[0]
                    && globalY >= client.at[1] && globalY <= client.at[1] + client.size[1]) {
                selection = Qt.rect(client.at[0] - (monitor?.x ?? 0), client.at[1] - (monitor?.y ?? 0), client.size[0], client.size[1]);
                confirming = true;
                return;
            }
        }
    }

    function capture() {
        if (selection.width < 2 || selection.height < 2 || countdownActive)
            return;

        const monitor = Hyprland.focusedMonitor;
        const globalX = Math.round((monitor?.x ?? 0) + selection.x);
        const globalY = Math.round((monitor?.y ?? 0) + selection.y);
        const width = Math.round(selection.width);
        const height = Math.round(selection.height);
        captureDelay.geometry = globalX + "," + globalY + " " + width + "x" + height;
        captureDelay.mode = captureMode;

        if (screenshotDelay > 0) {
            countdownRemaining = screenshotDelay;
            countdownActive = true;
            chromeVisible = false;
            countdownTimer.restart();
        } else {
            triggerCapture();
        }
    }

    function triggerCapture() {
        countdownActive = false;
        countdownRemaining = 0;
        chromeVisible = false;
        captureDelay.restart();
    }

    function cycleScreenshotDelay() {
        const currentIndex = screenshotDelays.indexOf(screenshotDelay);
        screenshotDelay = screenshotDelays[(currentIndex + 1) % screenshotDelays.length];
        updateSetting("screenCaptureDelay", screenshotDelay);
    }

    Component.onCompleted: loadSettings()

    Connections {
        target: Settings
        function onSettingsChanged() {
            loader.loadSettings();
        }
    }



    function startRecording() {
        if (selection.width < 2 || selection.height < 2 || recording || countdownActive) {
            return;
        }

        const monitor = Hyprland.focusedMonitor;
        const globalX = Math.round((monitor?.x ?? 0) + selection.x);
        const globalY = Math.round((monitor?.y ?? 0) + selection.y);
        const width = Math.max(2, Math.floor(selection.width / 2) * 2);
        const height = Math.max(2, Math.floor(selection.height / 2) * 2);
        const geometry = globalX + "," + globalY + " " + width + "x" + height;
        const now = new Date();
        const pad = value => value < 10 ? "0" + value : String(value);
        const filename = "recording-" + now.getFullYear() + pad(now.getMonth() + 1) + pad(now.getDate())
            + "-" + pad(now.getHours()) + pad(now.getMinutes()) + pad(now.getSeconds()) + ".mp4";

        recordingPath = "$HOME/Videos/Recordings/" + filename;
        recordingProcess.command = ["sh", "-c", "mkdir -p \"$HOME/Videos/Recordings\" && exec wf-recorder -g '" + geometry + "' -f \"" + recordingPath + "\""];
        chromeVisible = false;
        recording = true;
        recordingStartDelay.restart();
    }

    function stopRecording() {
        if (!recording) {
            return;
        }
        if (recordingStartDelay.running) {
            recordingStartDelay.stop();
            recording = false;
            resetSelection();
            active = false;
            return;
        }
        recordingProcess.running = false;
    }

    Timer {
        id: recordingStartDelay

        interval: 120
        onTriggered: recordingProcess.running = true;

    }

    Process {
        id: recordingProcess

        running: false

        stdout: SplitParser {
            splitMarker: "\n"
        }

        stderr: SplitParser {
            splitMarker: "\n"
        }

        onExited: (exitCode, exitStatus) => {
            if (!loader.recording) {
                return;
            }

            const completedPath = loader.recordingPath;
            loader.recording = false;
            if (completedPath !== "") {
                const safePath = completedPath.replace(/[^A-Za-z0-9_\-.$/]/g, "");
                Quickshell.execDetached(["notify-send", "-a", "quickshell", exitCode === 0 ? "Recording saved" : "Recording stopped", safePath]);
            }
            loader.resetSelection();
            loader.active = false;
        }
    }

    GlobalShortcut {
        name: "screen-capture"
        onPressed: loader.open()
    }

    Timer {
        id: countdownTimer

        interval: 1000
        repeat: true
        onTriggered: {
            loader.countdownRemaining--;
            if (loader.countdownRemaining <= 0) {
                stop();
                loader.triggerCapture();
            }
        }
    }

    Timer {
        id: captureDelay

        property string geometry: ""
        property string mode: "copysave"

        interval: 120
        onTriggered: {
            const safeGeometry = geometry.replace(/[^0-9x, +\-]/g, "");
            if (safeGeometry !== geometry)
                return;

            if (mode === "copy") {
                Quickshell.execDetached(["sh", "-c", "grim -t png -g '" + safeGeometry + "' - | wl-copy --type image/png"]);
                captureCloseDelay.restart();
                return;
            }

            const now = new Date();
            const pad = value => value < 10 ? "0" + value : String(value);
            const filename = "screenshot-" + now.getFullYear() + pad(now.getMonth() + 1) + pad(now.getDate())
                + "-" + pad(now.getHours()) + pad(now.getMinutes()) + pad(now.getSeconds()) + ".png";
            const path = "$HOME/Pictures/Screenshots/" + filename;
            let command = "mkdir -p \"$HOME/Pictures/Screenshots\" && grim -g '" + safeGeometry + "' \"" + path + "\"";
            if (mode === "copysave")
                command += " && wl-copy --type image/png < \"" + path + "\"";
            command += " && notify-send -a quickshell 'Screenshot captured' \"" + path + "\"";
            Quickshell.execDetached(["sh", "-c", command]);
            captureCloseDelay.restart();
        }
    }

    Timer {
        id: captureCloseDelay
        interval: 350
        onTriggered: loader.close()
    }

    sourceComponent: PanelWindow {
        id: panel

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        screen: Quickshell.screens.find(candidate => candidate.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        mask: Region {
            item: loader.recording ? recordingStopButton : loader.chromeVisible ? captureSurface : noInputTarget
        }

        WlrLayershell.namespace: "screen-capture"
        WlrLayershell.layer: WlrLayer.Overlay

        HyprlandFocusGrab {
            active: loader.active && loader.chromeVisible && !loader.recording
            windows: [panel]
            onCleared: {
                if (loader.chromeVisible && !loader.recording)
                    loader.close();
            }
        }

        Item {
            id: noInputTarget
            width: 0
            height: 0
        }

        Controls {
            id: controls
        }

        Item {
            id: captureSurface
            anchors.fill: parent
            focus: true

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: loader.close()
            }

            Keys.onPressed: event => {
                if (controls.escapePressed(event)) {
                    loader.close();
                    event.accepted = true;
                }
            }

            Rectangle {
                visible: loader.chromeVisible
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: loader.selection.y
                color: Colors.scrim
                opacity: 0.55
            }

            Rectangle {
                visible: loader.chromeVisible
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: loader.selection.y
                width: loader.selection.x
                height: loader.selection.height
                color: Colors.scrim
                opacity: 0.55
            }

            Rectangle {
                visible: loader.chromeVisible
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: loader.selection.y
                width: Math.max(0, parent.width - loader.selection.x - loader.selection.width)
                height: loader.selection.height
                color: Colors.scrim
                opacity: 0.55
            }

            Rectangle {
                visible: loader.chromeVisible
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Math.max(0, parent.height - loader.selection.y - loader.selection.height)
                color: Colors.scrim
                opacity: 0.55
            }

            Rectangle {
                visible: loader.chromeVisible && loader.selection.width > 0 && loader.selection.height > 0
                x: loader.selection.x
                y: loader.selection.y
                width: loader.selection.width
                height: loader.selection.height
                color: "transparent"
                border.color: Colors.onPrimary
                border.width: 1
            }

            Repeater {
                model: loader.confirming && loader.drawingTool === "select" ? loader.adjustmentHandles : []
                delegate: Rectangle {
                    required property var modelData
                    readonly property real handleSize: Math.max(8, Styles.marginSm)
                    visible: !recordingProcess.running
                    x: loader.selection.x + loader.selection.width * modelData.xFactor - handleSize / 2
                    y: loader.selection.y + loader.selection.height * modelData.yFactor - handleSize / 2
                    width: handleSize
                    height: handleSize
                    radius: handleSize / 2
                    color: Colors.primary
                }
            }

            Canvas {
                id: annotationCanvas

                visible: loader.confirming
                x: loader.selection.x
                y: loader.selection.y
                width: loader.selection.width
                height: loader.selection.height

                onPaint: {
                    const context = getContext("2d");
                    context.clearRect(0, 0, width, height);

                    function drawShape(shape) {
                        if (!shape)
                            return;
                        context.globalCompositeOperation = shape.type === "erase" ? "destination-out" : "source-over";
                        context.strokeStyle = shape.color;
                        context.lineWidth = shape.width;
                        context.lineCap = "round";
                        context.lineJoin = "round";

                        if (shape.type === "draw" || shape.type === "erase") {
                            if (shape.points.length < 2)
                                return;
                            context.beginPath();
                            context.moveTo(shape.points[0].x, shape.points[0].y);
                            for (let index = 1; index < shape.points.length; index++)
                                context.lineTo(shape.points[index].x, shape.points[index].y);
                            context.stroke();
                        } else if (shape.type === "line") {
                            context.beginPath();
                            context.moveTo(shape.startX, shape.startY);
                            context.lineTo(shape.endX, shape.endY);
                            context.stroke();
                        } else if (shape.type === "box") {
                            context.strokeRect(shape.startX, shape.startY, shape.endX - shape.startX, shape.endY - shape.startY);
                        }
                    }

                    for (let index = 0; index < loader.shapes.length; index++)
                        drawShape(loader.shapes[index]);
                    drawShape(loader.currentShape);
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: {
                    if (loader.drawingTool !== "select")
                        return Qt.ArrowCursor;
                    const mode = loader.adjustmentMode || loader.adjustmentModeAt(mouseX, mouseY);
                    if (mode === "move") return Qt.SizeAllCursor;
                    if (mode === "left" || mode === "right") return Qt.SizeHorCursor;
                    if (mode === "top" || mode === "bottom") return Qt.SizeVerCursor;
                    if (mode === "topLeft" || mode === "bottomRight") return Qt.SizeFDiagCursor;
                    if (mode === "topRight" || mode === "bottomLeft") return Qt.SizeBDiagCursor;
                    return Qt.CrossCursor;
                }
                enabled: loader.chromeVisible && !loader.countdownActive

                onPressed: mouse => {
                    if (toolbar.contains(toolbar.mapFromItem(this, mouse.x, mouse.y))) {
                        mouse.accepted = false;
                        return;
                    }
                    if (loader.confirming && loader.drawingTool !== "select") {
                        const localPoint = Qt.point(mouse.x - loader.selection.x, mouse.y - loader.selection.y);
                        if (localPoint.x < 0 || localPoint.y < 0 || localPoint.x > loader.selection.width || localPoint.y > loader.selection.height)
                            return;
                        loader.currentShape = loader.drawingTool === "draw" || loader.drawingTool === "erase"
                            ? { type: loader.drawingTool, points: [localPoint], color: loader.paintColor.toString(), width: loader.paintWidth }
                            : { type: loader.drawingTool, startX: localPoint.x, startY: localPoint.y, endX: localPoint.x, endY: localPoint.y, color: loader.paintColor.toString(), width: loader.paintWidth };
                        annotationCanvas.requestPaint();
                        return;
                    }
                    if (loader.targetMode === "window") {
                        loader.selectWindowAt(mouse.x, mouse.y);
                        return;
                    }
                    const adjustment = loader.adjustmentModeAt(mouse.x, mouse.y);
                    if (adjustment !== "") {
                        loader.adjustmentMode = adjustment;
                        loader.adjustmentStart = loader.selection;
                        loader.dragStart = Qt.point(mouse.x, mouse.y);
                        return;
                    }
                    loader.dragStart = Qt.point(mouse.x, mouse.y);
                    loader.selection = Qt.rect(mouse.x, mouse.y, 0, 0);
                    loader.dragging = true;
                }

                onPositionChanged: mouse => {
                    if (loader.currentShape) {
                        const localX = Math.max(0, Math.min(loader.selection.width, mouse.x - loader.selection.x));
                        const localY = Math.max(0, Math.min(loader.selection.height, mouse.y - loader.selection.y));
                        if (loader.currentShape.type === "draw" || loader.currentShape.type === "erase")
                            loader.currentShape.points.push({ x: localX, y: localY });
                        else {
                            loader.currentShape.endX = localX;
                            loader.currentShape.endY = localY;
                        }
                        annotationCanvas.requestPaint();
                    } else if (loader.adjustmentMode !== "") {
                        loader.adjustSelection(mouse.x, mouse.y, captureSurface.width, captureSurface.height);
                    } else if (loader.dragging) {
                        loader.selection = loader.normalizedSelection(loader.dragStart, Qt.point(mouse.x, mouse.y));
                    }
                }

                onReleased: mouse => {
                    if (loader.currentShape) {
                        loader.shapes.push(loader.currentShape);
                        loader.currentShape = null;
                        annotationCanvas.requestPaint();
                        return;
                    }
                    if (loader.adjustmentMode !== "") {
                        loader.adjustSelection(mouse.x, mouse.y, captureSurface.width, captureSurface.height);
                        loader.adjustmentMode = "";
                        return;
                    }
                    if (!loader.dragging)
                        return;
                    loader.selection = loader.normalizedSelection(loader.dragStart, Qt.point(mouse.x, mouse.y));
                    loader.dragging = false;
                    loader.confirming = loader.selection.width >= 2 && loader.selection.height >= 2;
                }
            }

            Rectangle {
                visible: loader.recording
                x: loader.selection.x - border.width
                y: loader.selection.y - border.width
                width: loader.selection.width + border.width * 2
                height: loader.selection.height + border.width * 2
                color: "transparent"
                border.color: Colors.error
                border.width: 2
            }

            ButtonStyled {
                id: recordingStopButton

                visible: loader.recording
                x: Math.max(Styles.marginSm, Math.min(parent.width - width - Styles.marginSm,
                    loader.selection.x + loader.selection.width / 2 - width / 2))
                y: loader.selection.y + loader.selection.height + height + Styles.marginSm <= parent.height
                    ? loader.selection.y + loader.selection.height + Styles.marginSm
                    : loader.selection.y - height - Styles.marginSm
                implicitHeight: 30
                text: Icons.close + " Stop"
                defaultColor: Colors.error
                textColor: Colors.onError
                onClicked: loader.stopRecording()
            }

            Rectangle {
                id: countdownIndicator

                visible: loader.countdownActive
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: Styles.marginMd
                width: 62
                height: 38
                radius: Styles.radiusSm
                color: Colors.surface
                border.color: Colors.primary
                border.width: 1

                TextStyled {
                    anchors.centerIn: parent
                    text: Icons.clock + " " + loader.countdownRemaining
                    color: Colors.onSurface
                    font.pixelSize: 18
                }
            }

            Rectangle {
                id: toolbar

                visible: loader.chromeVisible && !loader.countdownActive
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: Styles.marginMd
                width: toolbarRow.implicitWidth + Styles.marginMd * 2
                height: 50
                color: Colors.surface
                radius: Styles.radiusSm

                component Spacer: Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    color: Colors.outlineVariant
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: false
                    onPressed: mouse => mouse.accepted = true
                }

                RowLayout {
                    id: toolbarRow
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginMd

                    Repeater {
                        model: [
                            { icon: Icons.box, mode: "area" },
                            { icon: Icons.moveWindow, mode: "window" },
                            { icon: Icons.display, mode: "screen" }
                        ]

                        delegate: ButtonStyled {
                            required property var modelData
                            implicitWidth: 30
                            implicitHeight: 30
                            text: modelData.icon
                            isFocused: loader.targetMode === modelData.mode
                            defaultColor: isFocused ? Colors.primary : Colors.surfaceVariant
                            textColor: isFocused ? Colors.onPrimary : Colors.onSurface
                            onClicked: {
                                loader.resetSelection();
                                loader.targetMode = modelData.mode;
                                loader.updateSetting("screenCaptureTargetMode", modelData.mode);
                                if (modelData.mode === "screen")
                                    loader.selectFullScreen(captureSurface.width, captureSurface.height);
                            }
                        }
                    }

                    Spacer {}

                    ButtonStyled {
                        implicitWidth: 30
                        implicitHeight: 30
                        text: Icons.close
                        defaultColor: Colors.error
                        textColor: Colors.onError
                        onClicked: loader.close()
                    }
                }
            }

            Rectangle {
                id: confirmation

                visible: loader.chromeVisible && loader.confirming && !loader.countdownActive
                x: Math.max(Styles.marginSm, Math.min(parent.width - width - Styles.marginSm, loader.selection.x + loader.selection.width / 2 - width / 2))
                y: loader.targetMode === "screen" || loader.targetMode === "window"
                    ? toolbar.y + toolbar.height + Styles.marginSm
                    : loader.selection.y >= height + Styles.marginSm * 2
                        ? loader.selection.y - height - Styles.marginSm
                        : loader.selection.y + loader.selection.height + height + Styles.marginSm * 2 <= parent.height
                            ? loader.selection.y + loader.selection.height + Styles.marginSm
                            : Math.max(Styles.marginSm, loader.selection.y + Styles.marginSm)
                width: confirmationRow.implicitWidth + Styles.marginMd * 2
                height: 50
                color: Colors.surface
                radius: Styles.radiusSm

                RowLayout {
                    id: confirmationRow
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginMd

                    Repeater {
                        model: [
                            { mode: "error", color: Colors.error },
                            { mode: "primary", color: Colors.primary },
                            { mode: "tertiary", color: Colors.tertiary },
                            { mode: "onSurface", color: Colors.onSurface }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            width: 24
                            height: 24
                            radius: 12
                            color: modelData.color
                            border.width: loader.paintColorMode === modelData.mode ? 2 : 0
                            border.color: Colors.onSurface

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    loader.paintColorMode = parent.modelData.mode;
                                    loader.updateSetting("screenCapturePaintColor", parent.modelData.mode);
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: Colors.outlineVariant
                    }

                    Repeater {
                        model: [
                            { icon: Icons.pen, tool: "draw" },
                            { icon: Icons.line, tool: "line" },
                            { icon: Icons.box, tool: "box" },
                            { icon: Icons.eraser, tool: "erase" }
                        ]

                        delegate: ButtonStyled {
                            required property var modelData
                            implicitHeight: 30
                            text: modelData.icon
                            isFocused: loader.drawingTool === modelData.tool
                            defaultColor: isFocused ? Colors.primary : Colors.surfaceVariant
                            textColor: isFocused ? Colors.onPrimary : Colors.onSurface
                            onClicked: {
                                loader.drawingTool = isFocused ? "select" : modelData.tool;
                                loader.updateSetting("screenCaptureDrawingTool", loader.drawingTool);
                            }
                        }
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.undo
                        defaultColor: Colors.surfaceVariant
                        textColor: Colors.onSurface
                        onClicked: {
                            if (loader.shapes.length > 0) {
                                loader.shapes.pop();
                                annotationCanvas.requestPaint();
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: Colors.outlineVariant
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.reset
                        defaultColor: Colors.surfaceVariant
                        textColor: Colors.onSurface
                        onClicked: loader.resetSelection()
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: Colors.outlineVariant
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.clock + " " + loader.screenshotDelay + "s"
                        isFocused: loader.screenshotDelay > 0
                        defaultColor: isFocused ? Colors.primary : Colors.surfaceVariant
                        textColor: isFocused ? Colors.onPrimary : Colors.onSurface
                        onClicked: loader.cycleScreenshotDelay()
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.video
                        defaultColor: Colors.error
                        textColor: Colors.onError
                        onClicked: loader.startRecording()
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: Colors.outlineVariant
                    }

                    Repeater {
                        model: [
                            { icon: Icons.copy, mode: "copy" },
                            { icon: Icons.save, mode: "save" },
                            { icon: Icons.image, mode: "copysave" }
                        ]

                        delegate: ButtonStyled {
                            required property var modelData
                            implicitWidth: 30
                            implicitHeight: 30
                            text: modelData.icon
                            isFocused: loader.captureMode === modelData.mode
                            defaultColor: isFocused ? Colors.primary : Colors.surfaceVariant
                            textColor: isFocused ? Colors.onPrimary : Colors.onSurface
                            onClicked: {
                                loader.captureMode = modelData.mode;
                                loader.updateSetting("screenCaptureMode", modelData.mode);
                            }
                        }
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.image
                        defaultColor: Colors.primary
                        textColor: Colors.onPrimary
                        onClicked: loader.capture()
                    }
                }
            }
        }
    }
}
