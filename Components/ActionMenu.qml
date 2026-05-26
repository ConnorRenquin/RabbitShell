pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Widgets

import qs.Settings

Item {
    id: root

    implicitWidth: menuButton.implicitWidth
    implicitHeight: menuButton.implicitHeight

    property alias text: menuButton.text
    property alias textColor: menuButton.textColor
    property alias pointSize: menuButton.pointSize
    property alias defaultColor: menuButton.defaultColor
    property alias radius: menuButton.radius
    property alias popupVisible: menuPopup.visible
    property alias containsMouse: menuButton.containsMouse

    property var iconSource: ""
    property int iconSize: 20
    property color popupColor: "transparent"
    property real popupRadius: Styles.radiusSm
    property real popupPadding: Styles.marginXS
    property real popupWidth: popupContent.implicitWidth + root.popupPadding * 2
    property real popupHeight: popupContent.implicitHeight + root.popupPadding * 2
    property real popupX: -menuPopup.width / 2 + menuButton.width / 2
    property real popupY: Settings.get('barPosition').value ? Styles.marginSm * 5 : -menuPopup.height - Styles.marginMd
    property bool autoHide: true
    property int autoHideInterval: 500

    default property alias content: popupContent.data

    signal clicked(var mouse)
    signal popupClosed()

    function togglePopup() {
        menuPopup.visible = !menuPopup.visible;
    }

    function closePopup() {
        menuPopup.visible = false;
    }

    ButtonStyled {
        id: menuButton
        anchors.fill: parent

        onClicked: mouse => root.clicked(mouse)

        IconImage {
            visible: root.iconSource !== "" && root.iconSource !== null
            anchors.centerIn: parent
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
            source: root.iconSource || ""
        }
    }

    PopupWindow {
        id: menuPopup

        implicitWidth: root.popupWidth
        implicitHeight: root.popupHeight
        color: "transparent"

        onVisibleChanged: {
            if (!visible) {
                root.popupClosed();
            }
        }

        anchor {
            item: menuButton
            rect.x: root.popupX
            rect.y: root.popupY
        }

        HoverHandler {
            id: popupHover
        }

        Timer {
            interval: root.autoHideInterval
            running: root.autoHide && menuPopup.visible && !popupHover.hovered && !menuButton.containsMouse
            onTriggered: menuPopup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            visible: menuPopup.visible
            radius: root.popupRadius
            color: root.popupColor

            Item {
                id: popupContent
                anchors.fill: parent
                anchors.margins: root.popupPadding
            }
        }
    }
}
