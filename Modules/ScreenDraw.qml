pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components
import qs.Helpers

Loader {
    id: loader

    active: false

    function toggle() {
        loader.active = !loader.active;
    }

    GlobalShortcut {
        name: "screendraw"
        onPressed: loader.toggle()
    }

    sourceComponent: PanelWindow {
        id: root

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        onClosed: loader.active = false
        WlrLayershell.namespace: "screendraw"
        WlrLayershell.layer: WlrLayer.Overlay

        // Grab focus so we can capture key events (like Esc to clear) and mouse events
        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }


        // Canvas for drawing
        Canvas {
            id: canvas
            anchors.fill: parent

            focus: true

            Controls {
                id: controls
            }

            property var shapes: []
            property var currentShape: null

            property color paintColor: "#E67E80"
            property int paintWidth: 6
            property string paintMode: "draw"

            function clearCanvas() {
                shapes = [];
                currentShape = null;
                requestPaint();
            }

            function undo() {
                if (shapes.length > 0) {
                    shapes.pop();
                    requestPaint();
                }
            }

            Keys.onPressed: event => {
                if (controls.escapePressed(event)) {
                    loader.active = false;
                    event.accepted = true;
                }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, canvas.width, canvas.height);

                function drawShape(shape) {
                    if (!shape) return;

                    if (shape.type === "erase") {
                        ctx.globalCompositeOperation = "destination-out";
                    } else {
                        ctx.globalCompositeOperation = "source-over";
                    }
                    ctx.strokeStyle = shape.color;
                    ctx.lineWidth = shape.width;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";

                    if (shape.type === "draw" || shape.type === "erase") {
                        if (shape.points.length < 2) return;
                        ctx.beginPath();
                        ctx.moveTo(shape.points[0].x, shape.points[0].y);
                        for (var i = 1; i < shape.points.length; i++) {
                            ctx.lineTo(shape.points[i].x, shape.points[i].y);
                        }
                        ctx.stroke();
                    } else if (shape.type === "line") {
                        ctx.beginPath();
                        ctx.moveTo(shape.startX, shape.startY);
                        ctx.lineTo(shape.endX, shape.endY);
                        ctx.stroke();
                    } else if (shape.type === "box") {
                        ctx.beginPath();
                        ctx.rect(shape.startX, shape.startY, shape.endX - shape.startX, shape.endY - shape.startY);
                        ctx.stroke();
                    }
                }

                // Draw all saved shapes
                for (var i = 0; i < shapes.length; i++) {
                    drawShape(shapes[i]);
                }

                // Draw current preview shape
                if (currentShape) {
                    drawShape(currentShape);
                }
            }
        }

        // MouseArea covering the entire screen to capture drawing gestures
        MouseArea {
            anchors.fill: parent
            hoverEnabled: false

            onPressed: mouse => {
                if (toolbar.contains(toolbar.mapFromItem(this, mouse.x, mouse.y))) {
                    mouse.accepted = false;
                    return;
                }

                if (canvas.paintMode === "draw" || canvas.paintMode === "erase") {
                    canvas.currentShape = {
                        type: canvas.paintMode,
                        points: [{ x: mouse.x, y: mouse.y }],
                        color: canvas.paintColor.toString(),
                        width: canvas.paintWidth
                    };
                } else if (canvas.paintMode === "line" || canvas.paintMode === "box") {
                    canvas.currentShape = {
                        type: canvas.paintMode,
                        startX: mouse.x,
                        startY: mouse.y,
                        endX: mouse.x,
                        endY: mouse.y,
                        color: canvas.paintColor.toString(),
                        width: canvas.paintWidth
                    };
                }
                canvas.requestPaint();
            }

            onPositionChanged: mouse => {
                if (!canvas.currentShape) return;

                if (canvas.paintMode === "draw" || canvas.paintMode === "erase") {
                    canvas.currentShape.points.push({ x: mouse.x, y: mouse.y });
                } else if (canvas.paintMode === "line" || canvas.paintMode === "box") {
                    canvas.currentShape.endX = mouse.x;
                    canvas.currentShape.endY = mouse.y;
                }
                canvas.requestPaint();
            }

            onReleased: mouse => {
                if (canvas.currentShape) {
                    canvas.shapes.push(canvas.currentShape);
                    canvas.currentShape = null;
                    canvas.requestPaint();
                }
            }
        }

        Rectangle {
            id: toolbar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Styles.marginMd
            width: toolbarLayout.implicitWidth + Styles.marginMd * 2
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
                id: toolbarLayout
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginMd
                RowLayout {
                    spacing: Styles.marginSm
                    Repeater {
                        model: [
                            { color: "#E67E80", name: "Red" },
                            { color: "#A7C080", name: "Green" },
                            { color: "#7FBBB3", name: "Blue" },
                            { color: "#DBBC7F", name: "Yellow" },
                            { color: "#FFFFFF", name: "White" }
                        ]
                        delegate: Rectangle {
                            id: colorCircle
                            required property var modelData
                            width: 24
                            height: 24
                            radius: 12
                            color: colorCircle.modelData.color
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    canvas.paintColor = colorCircle.modelData.color;
                                    if (canvas.paintMode === "erase") {
                                        canvas.paintMode = "draw";
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer{}

                RowLayout {
                    spacing: Styles.marginSm

                    Repeater {
                        model: [
                            { size: 3, label: "S" },
                            { size: 8, label: "M" },
                            { size: 16, label: "L" }
                        ]

                        delegate: ButtonStyled {
                            required property var modelData
                            implicitWidth: 30
                            implicitHeight: 30
                            text: modelData.label
                            isFocused: canvas.paintWidth === modelData.size
                            defaultColor: canvas.paintWidth === modelData.size ? Colors.primary : Colors.surfaceVariant
                            textColor: canvas.paintWidth === modelData.size ? Colors.onPrimary : Colors.onSurface

                            onClicked: {
                                canvas.paintWidth = modelData.size;
                            }
                        }
                    }
                }

                Spacer {}

                // Tools (Pen, Line, Box, Eraser)
                RowLayout {
                    spacing: Styles.marginSm

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.pen
                        isFocused: canvas.paintMode === "draw"
                        defaultColor: canvas.paintMode === "draw" ? Colors.primary : Colors.surfaceVariant
                        textColor: canvas.paintMode === "draw" ? Colors.onPrimary : Colors.onSurface
                        onClicked: canvas.paintMode = "draw"
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.line
                        isFocused: canvas.paintMode === "line"
                        defaultColor: canvas.paintMode === "line" ? Colors.primary : Colors.surfaceVariant
                        textColor: canvas.paintMode === "line" ? Colors.onPrimary : Colors.onSurface
                        onClicked: canvas.paintMode = "line"
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.box
                        isFocused: canvas.paintMode === "box"
                        defaultColor: canvas.paintMode === "box" ? Colors.primary : Colors.surfaceVariant
                        textColor: canvas.paintMode === "box" ? Colors.onPrimary : Colors.onSurface
                        onClicked: canvas.paintMode = "box"
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.eraser
                        isFocused: canvas.paintMode === "erase"
                        defaultColor: canvas.paintMode === "erase" ? Colors.primary : Colors.surfaceVariant
                        textColor: canvas.paintMode === "erase" ? Colors.onPrimary : Colors.onSurface
                        onClicked: canvas.paintMode = "erase"
                    }
                }

                Spacer {}

                RowLayout {
                    id: actionsRow
                    spacing: Styles.marginSm

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.undo
                        defaultColor: Colors.surfaceVariant
                        textColor: Colors.onSurface
                        onClicked: canvas.undo()
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.trash
                        defaultColor: Colors.surfaceVariant
                        textColor: Colors.onSurface
                        onClicked: canvas.clearCanvas()
                    }

                    ButtonStyled {
                        implicitHeight: 30
                        text: Icons.close
                        defaultColor: Colors.error
                        textColor: Colors.onError
                        onClicked: loader.active = false
                    }
                }
            }
        }
    }
}
