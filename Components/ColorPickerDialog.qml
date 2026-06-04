import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
import qs.Components.Styled

Rectangle {
    id: root

    z: 10
    visible: false
    anchors.centerIn: parent
    width: 480
    height: column.implicitHeight + Styles.marginSm * 2
    radius: Styles.radiusLg
    color: Qt.lighter(Colors.surface, Colors.lighter)

    property string title: "Select Color"
    property color initialColor: "#ffffff"

    signal accepted(string hexColor)
    signal canceled

    // Internal HSV state to prevent loss of hue when saturation/value is 0
    property real currentHue: 0.0
    property real currentSaturation: 1.0
    property real currentValue: 1.0

    readonly property color currentColor: Qt.hsva(currentHue, currentSaturation, currentValue, 1.0)

    onVisibleChanged: {
        if (visible) {
            var c = Qt.color(initialColor);
            currentHue = c.hsvHue >= 0 ? c.hsvHue : 0.0;
            currentSaturation = c.hsvSaturation;
            currentValue = c.hsvValue;
        }
    }

    function colorToHex(c) {
        var r = Math.round(c.r * 255).toString(16).padStart(2, '0');
        var g = Math.round(c.g * 255).toString(16).padStart(2, '0');
        var b = Math.round(c.b * 255).toString(16).padStart(2, '0');
        return "#" + r + g + b;
    }

    function updateFromRGB(r, g, b) {
        var c = Qt.rgba(r, g, b, 1.0);
        if (c.hsvHue >= 0) {
            currentHue = c.hsvHue;
        }
        currentSaturation = c.hsvSaturation;
        currentValue = c.hsvValue;
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginMd

        TextStyled {
            text: root.title
            font.pointSize: Styles.textMd
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: Styles.marginMd
            Layout.fillWidth: true

            // Color Wheel
            Item {
                Layout.preferredHeight: 160
                Layout.preferredWidth: 160
                Layout.alignment: Qt.AlignVCenter

                Canvas {
                    id: colorWheel
                    anchors.fill: parent

                    onPaint: {
                        var ctx = getContext("2d");
                        var cx = width / 2;
                        var cy = height / 2;
                        var radius = Math.min(cx, cy);

                        ctx.clearRect(0, 0, width, height);

                        for (var angle = 0; angle < 360; angle++) {
                            var startAngle = (angle - 0.5) * Math.PI / 180;
                            var endAngle = (angle + 1.5) * Math.PI / 180;

                            ctx.beginPath();
                            ctx.moveTo(cx, cy);
                            ctx.arc(cx, cy, radius, startAngle, endAngle, false);
                            ctx.closePath();

                            var gradient = ctx.createRadialGradient(cx, cy, 0, cx, cy, radius);
                            gradient.addColorStop(0, 'white');
                            gradient.addColorStop(1, 'hsl(' + angle + ', 100%, 50%)');

                            ctx.fillStyle = gradient;
                            ctx.fill();
                        }
                    }
                }

                // Drag Handle
                Rectangle {
                    id: handle
                    width: 14
                    height: 14
                    radius: 7
                    color: "transparent"
                    border.color: "black"
                    border.width: 2

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 5
                        color: "transparent"
                        border.color: "white"
                        border.width: 1
                    }

                    x: (colorWheel.width / 2) + (root.currentSaturation * (Math.min(colorWheel.width, colorWheel.height) / 2) * Math.cos(root.currentHue * 2 * Math.PI)) - width / 2
                    y: (colorWheel.height / 2) + (root.currentSaturation * (Math.min(colorWheel.width, colorWheel.height) / 2) * Math.sin(root.currentHue * 2 * Math.PI)) - height / 2
                }

                MouseArea {
                    id: wheelMouseArea
                    anchors.fill: parent

                    function updateFromMouse(mouse) {
                        var cx = width / 2;
                        var cy = height / 2;
                        var radius = Math.min(cx, cy);

                        var dx = mouse.x - cx;
                        var dy = mouse.y - cy;
                        var distance = Math.sqrt(dx*dx + dy*dy);

                        var sat = Math.min(1.0, distance / radius);

                        var angle = Math.atan2(dy, dx);
                        var hue = angle / (2 * Math.PI);
                        if (hue < 0) {
                            hue += 1.0;
                        }

                        root.currentHue = hue;
                        root.currentSaturation = sat;
                    }

                    onPressed: mouse => updateFromMouse(mouse)
                    onPositionChanged: mouse => updateFromMouse(mouse)
                }
            }

            // Sliders
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styles.marginSm

                // Lightness/Darkness Slider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        TextStyled {
                            text: "Lightness"
                            font.pointSize: Styles.textSm
                        }
                        Item { Layout.fillWidth: true }
                        TextStyled {
                            text: Math.round(root.currentValue * 100) + "%"
                            font.pointSize: Styles.textSm
                        }
                    }

                    SliderSmallStyled {
                        Layout.fillWidth: true
                        value: root.currentValue
                        stepSize: 0.01
                        showPercentage: false
                        onMoved: root.currentValue = value
                    }
                }

                // Red Slider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        TextStyled {
                            text: "Red"
                            font.pointSize: Styles.textSm
                        }
                        Item { Layout.fillWidth: true }
                        TextStyled {
                            text: Math.round(root.currentColor.r * 255)
                            font.pointSize: Styles.textSm
                        }
                    }

                    SliderSmallStyled {
                        Layout.fillWidth: true
                        value: root.currentColor.r
                        stepSize: 0.003921568 // 1/255
                        showPercentage: false
                        onMoved: root.updateFromRGB(value, root.currentColor.g, root.currentColor.b)
                    }
                }

                // Green Slider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        TextStyled {
                            text: "Green"
                            font.pointSize: Styles.textSm
                        }
                        Item { Layout.fillWidth: true }
                        TextStyled {
                            text: Math.round(root.currentColor.g * 255)
                            font.pointSize: Styles.textSm
                        }
                    }

                    SliderSmallStyled {
                        Layout.fillWidth: true
                        value: root.currentColor.g
                        stepSize: 0.003921568 // 1/255
                        showPercentage: false
                        onMoved: root.updateFromRGB(root.currentColor.r, value, root.currentColor.b)
                    }
                }

                // Blue Slider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        TextStyled {
                            text: "Blue"
                            font.pointSize: Styles.textSm
                        }
                        Item { Layout.fillWidth: true }
                        TextStyled {
                            text: Math.round(root.currentColor.b * 255)
                            font.pointSize: Styles.textSm
                        }
                    }

                    SliderSmallStyled {
                        Layout.fillWidth: true
                        value: root.currentColor.b
                        stepSize: 0.003921568 // 1/255
                        showPercentage: false
                        onMoved: root.updateFromRGB(root.currentColor.r, root.currentColor.g, value)
                    }
                }
            }
        }

        // Preview section
        RowLayout {
            Layout.fillWidth: true
            spacing: Styles.marginMd

            TextStyled {
                text: "Preview:"
                font.pointSize: Styles.textSm
            }

            Rectangle {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 30
                color: root.initialColor
                radius: Styles.radiusSm
            }

            Rectangle {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 30
                color: root.currentColor
                radius: Styles.radiusSm
            }

            TextStyled {
                text: root.colorToHex(root.currentColor).toUpperCase()
                font.pointSize: Styles.textSm
                font.bold: true
            }
        }

        // Action Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: Styles.marginSm

            ButtonStyled {
                Layout.fillWidth: true
                text: "Accept"
                onClicked: {
                    root.accepted(root.colorToHex(root.currentColor));
                    root.visible = false;
                }
            }

            ButtonStyled {
                Layout.fillWidth: true
                text: "Cancel"
                onClicked: {
                    root.canceled();
                    root.visible = false;
                }
            }
        }
    }
}
