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
    property string hoverColor: Colors.surfaceLighter
    property string defaultColor: Colors.surface
    property string focusedColor: Colors.surfaceLighter
    property bool isFocused: false
    property bool containsMouse: mouseArea.containsMouse

    default property alias content: contentItem.data

    property alias textAlignment: buttonText.horizontalAlignment

    // TODO Have size effected by clicked.
    signal clicked(var mouse)

    ColorAnimation on color {
        duration: 50
    }

    NumberAnimation on scale {
        duration: 50
    }

    TextStyled {
        id: buttonText
        visible: root.text
        anchors.fill: parent
        anchors.margins: Styles.marginSm
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
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: mouse => root.clicked(mouse)
    }
}
