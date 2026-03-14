import QtQuick

import qs.Settings

Rectangle {
    id: root

    color: {
        if (mouseArea.containsMouse)
            return hoverColor;
        if (isFocused)
            return focusedColor;
        else
            return defaultColor;
    }

    radius: Styles.radiusSm
    scale: mouseArea.pressed ? 0.95 : 1
    implicitWidth: buttonText.implicitWidth + Styles.marginMd
    implicitHeight: buttonText.implicitHeight + Styles.marginMd

    property string text

    property alias pixelSize: buttonText.font.pixelSize
    property string hoverColor: Colors.backgroundHighlighted
    property string defaultColor: Colors.background
    property string focusedColor: Colors.backgroundHighlighted
    property bool isFocused: false
    property bool containsMouse: mouseArea.containsMouse

    default property alias content: contentItem.data
    // TODO Have size effected by clicked.
    signal clicked(var mouse)

    Behavior on color {
        ColorAnimation {
            duration: 50
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 50
        }
    }

    TextStyled {
        id: buttonText
        visible: root.text
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.text
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        // propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => root.clicked(mouse)
    }
}
