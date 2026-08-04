

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
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
    property color paintColor: Colors.error
    property int paintWidth: 6
    property var shapes: []
    property var currentShape: null
    property bool chromeVisible: true
    property point dragStart: Qt.point(0, 0)
    property rect selection: Qt.rect(0, 0, 0, 0)
    property bool dragging: false
    property bool confirming: false

    function resetSelection() {
        selection = Qt.rect(0, 0, 0, 0);
        dragging = false;
        confirming = false;
        drawingTool = "select";
        shapes = [];
        currentShape = null;
        chromeVisible = true;
    }

    function open() {
        resetSelection();
        targetMode = "area";
        active = true;
    }

    function close() {
        resetSelection();
        active = false;
    }

    function normalizedSelection(start, end) {
        const left = Math.min(start.x, end.x);
        const top = Math.min(start.y, end.y);
        return Qt.rect(left, top, Math.abs(end.x - start.x), Math.abs(end.y - start.y));
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
        if (selection.width < 2 || selection.height < 2)
            return;

        const monitor = Hyprland.focusedMonitor;
        const globalX = Math.round((monitor?.x ?? 0) + selection.x);
        const globalY = Math.round((monitor?.y ?? 0) + selection.y);
        const width = Math.round(selection.width);
        const height = Math.round(selection.height);
        const geometry = globalX + "," + globalY + " " + width + "x" + height;
        const mode = captureMode;

        chromeVisible = false;
        captureDelay.geometry = geometry;
        captureDelay.mode = mode;
        captureDelay.restart();
    }

    GlobalShortcut {
        name: "screen-capture"
        onPressed: loader.open()
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
                Quickshell.execDetached(["sh", "-c", "grim -g '" + safeGeometry + "' - | wl-copy --type image/png"]);
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

        WlrLayershell.namespace: "screen-capture"
        WlrLayershell.layer: WlrLayer.Overlay

        HyprlandFocusGrab {
            active: loader.active
            windows: [panel]
            onCleared: loader.close()
        }

        Controls {
            id: controls
        }

        Item {
            id: captureSurface
            anchors.fill: parent
            focus: true

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
                opacity: 0.65
            }

            Rectangle {
                visible: loader.chromeVisible
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: loader.selection.y
                width: loader.selection.x
                height: loader.selection.height
                color: Colors.scrim
                opacity: 0.65
            }

            Rectangle {
                visible: loader.chromeVisible
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: loader.selection.y
                width: Math.max(0, parent.width - loader.selection.x - loader.selection.width)
                height: loader.selection.height
                color: Colors.scrim
                opacity: 0.65
            }

            Rectangle {
                visible: loader.chromeVisible
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Math.max(0, parent.height - loader.selection.y - loader.selection.height)
                color: Colors.scrim
                opacity: 0.65
            }

            Rectangle {
                visible: loader.chromeVisible && loader.selection.width > 0 && loader.selection.height > 0
                x: loader.selection.x
                y: loader.selection.y
                width: loader.selection.width
                height: loader.selection.height
                color: "transparent"
                border.color: Colors.primary
                border.width: 2
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
                cursorShape: loader.drawingTool === "select" ? Qt.CrossCursor : Qt.ArrowCursor
                enabled: loader.chromeVisible

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
                    if (!loader.dragging)
                        return;
                    loader.selection = loader.normalizedSelection(loader.dragStart, Qt.point(mouse.x, mouse.y));
                    loader.dragging = false;
                    loader.confirming = loader.selection.width >= 2 && loader.selection.height >= 2;
                }
            }

            Rectangle {
                id: toolbar

                visible: loader.chromeVisible
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
                                if (modelData.mode === "screen")
                                    loader.selectFullScreen(captureSurface.width, captureSurface.height);
                            }
                        }
                    }

                    Spacer {}

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
                            onClicked: loader.captureMode = modelData.mode
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

                visible: loader.chromeVisible && loader.confirming
                x: Math.max(Styles.marginSm, Math.min(parent.width - width - Styles.marginSm, loader.selection.x + loader.selection.width / 2 - width / 2))
                y: Math.max(Styles.marginSm, Math.min(parent.height - height - Styles.marginSm, loader.selection.y + loader.selection.height + Styles.marginSm))
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
                        model: [Colors.error, Colors.primary, Colors.tertiary, Colors.onSurface]

                        delegate: Rectangle {
                            required property var modelData
                            width: 24
                            height: 24
                            radius: 12
                            color: modelData
                            border.width: loader.paintColor.toString() === modelData.toString() ? 2 : 0
                            border.color: Colors.onSurface

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: loader.paintColor = parent.modelData
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
                            implicitWidth: 30
                            implicitHeight: 30
                            text: modelData.icon
                            isFocused: loader.drawingTool === modelData.tool
                            defaultColor: isFocused ? Colors.primary : Colors.surfaceVariant
                            textColor: isFocused ? Colors.onPrimary : Colors.onSurface
                            onClicked: loader.drawingTool = modelData.tool
                        }
                    }

                    ButtonStyled {
                        implicitWidth: 30
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
                        implicitWidth: 30
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
                        implicitWidth: 30
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
