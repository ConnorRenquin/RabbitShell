import QtQuick
import QtQuick.Controls

import qs.Components
import qs.Settings

Slider {
    id: root

    stepSize: 0.05
    from: 0
    to: 1

    property color backgroundColor: Colors.background
    property color progressColor: Colors.foreground
    property color handleColor: Colors.foreground
    property color handleHoverColor: Colors.foreground
    property color handleTextColor: Colors.backgroundLifted
    property int handleHeight: 30
    property bool showPercentage: true

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2

        implicitWidth: 100
        implicitHeight: 4

        radius: Styles.radiusSm
        color: root.backgroundColor

        Rectangle {
            implicitWidth: root.visualPosition * parent.width
            implicitHeight: parent.height
            color: root.progressColor
            radius: Styles.radiusSm
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2

        implicitWidth: 60
        implicitHeight: root.handleHeight

        radius: Styles.radiusSm
        color: handleMouseArea.containsMouse ? root.handleHoverColor : root.handleColor

        ColorAnimation on color {
            duration: 200
        }

        TextStyled {
            id: handleText
            visible: root.showPercentage
            anchors.centerIn: parent
            color: root.handleTextColor
            font.pixelSize: Styles.textSm
            text: `${Math.floor(root.value * 100)}%`
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
