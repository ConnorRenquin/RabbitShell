import Quickshell
import Quickshell.Widgets
import QtQuick
import Quickshell.Services.SystemTray

import qs.Components
import qs.Constants

PopupWindow {
    id: root

    required property Item parentItem
    property QsMenuHandle trayMenu

    property int baseMargin: 15

    anchor {
        item: parentItem
        rect.y: parentItem.height + 15
        rect.x: parentItem.implicitWidth / 2 - implicitWidth / 2
    }

    color: "transparent"
    implicitHeight: menuBackground.implicitHeight + root.baseMargin
    implicitWidth: menuBackground.implicitWidth + root.baseMargin

    QsMenuOpener {
        id: menuOpener
        menu: root.trayMenu
    }

    Rectangle {
        id: menuBackground
        color: Colors.bgDim
        radius: 10
        anchors.fill: parent
        implicitHeight: contentColumn.implicitHeight
        implicitWidth: contentColumn.implicitWidth

        Column {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                centerIn: parent
            }
            spacing: 10
            Repeater {
                model: menuOpener.children.values
                delegate: Rectangle {
                    id: menuItem

                    property bool hovered: false
                    property bool pressed: false

                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.bg1
                    radius: 5
                    implicitWidth: 200
                    implicitHeight: modelData.isSeperator || modelData.text == "" ? 2 : (textContent.implicitHeight + 10)

                    TextStyled {
                        id: textContent
                        anchors.centerIn: parent
                        text: modelData.text
                        width: parent.width - root.baseMargin
                        wrapMode: Text.WordWrap
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: {
                            menuItem.pressed = true;
                        }
                        onReleased: {
                            menuItem.pressed = false;
                        }
                        onClicked: event => {
                            modelData.triggered();
                        }
                    }
                }
            }
        }
    }
}
