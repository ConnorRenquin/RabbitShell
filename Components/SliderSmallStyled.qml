import QtQuick
import QtQuick.Controls

import qs.Components
import qs.Settings

Slider {
    id: root

    stepSize: 0.05
    from: 0
    to: 1

    property color backgroundColor: Colors.surface
    property color progressColor: Colors.onSurface
    property color handleColor: Colors.onSurface
    property color handleHoverColor: Colors.onSurface
    property color handleTextColor: Qt.lighter(Colors.surface, Colors.lighter)
    property int lineHeight: 2
    property int handleSize: 12
    property int handleHoverSize: 14
    property int percentageBoxWidth: 42
    property int percentageBoxHeight: 22
    property int percentageBoxSpacing: 8
    property bool showPercentage: true

    readonly property int percentageOffset: showPercentage ? percentageBoxWidth + percentageBoxSpacing : 0
    readonly property int trackWidth: Math.max(0, availableWidth - percentageOffset)

    background: Item {
        x: root.leftPadding
        y: root.topPadding

        implicitWidth: 100
        implicitHeight: Math.max(root.percentageBoxHeight, root.handleHoverSize)

        Rectangle {
            id: percentageBox
            visible: root.showPercentage
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            implicitWidth: root.percentageBoxWidth
            implicitHeight: root.percentageBoxHeight

            radius: Styles.radiusSm
            color: root.handleColor

            ColorAnimation on color {
                duration: 200
            }

            TextStyled {
                id: percentageText
                anchors.centerIn: parent
                color: root.handleTextColor
                font.pointSize: Styles.textSm
                text: `${Math.floor(root.value * 100)}%`
            }
        }

        Rectangle {
            id: track
            x: root.percentageOffset
            anchors.verticalCenter: parent.verticalCenter

            implicitWidth: root.trackWidth
            implicitHeight: root.lineHeight

            radius: height / 2
            color: root.backgroundColor

            Rectangle {
                implicitWidth: root.visualPosition * parent.width
                implicitHeight: parent.height
                color: root.progressColor
                radius: parent.radius
            }
        }
    }

    handle: Rectangle {
        readonly property int currentSize: handleMouseArea.containsMouse ? root.handleHoverSize : root.handleSize

        x: root.leftPadding + root.percentageOffset + root.visualPosition * (root.trackWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2

        implicitWidth: currentSize
        implicitHeight: currentSize

        radius: width / 2
        color: handleMouseArea.containsMouse ? root.handleHoverColor : root.handleColor

        Behavior on implicitWidth {
            NumberAnimation { duration: 120 }
        }

        Behavior on implicitHeight {
            NumberAnimation { duration: 120 }
        }

        ColorAnimation on color {
            duration: 200
        }

        MouseArea {
            id: handleMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.NoButton
        }
    }
}
