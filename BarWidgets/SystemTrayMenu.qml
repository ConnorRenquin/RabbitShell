import Quickshell
import QtQuick
import Quickshell.Services.SystemTray

import qs.Global
import qs.Constants

PopupWindow {
    id: root

    required property Item parentItem
    property QsMenuHandle trayMenu

    anchor {
        item: parentItem
        rect.y: parentItem.height + 15
        rect.x: parentItem.width / 2 - width / 2
    }

    color: "transparent"
    implicitHeight: contentColumn.height + 20
    width: menuBackground.width

    QsMenuOpener {
        id: menuOpener
        menu: root.trayMenu
    }

    Rectangle {
        id: menuBackground
        color: Colors.bgDim
        radius: 10
        width: contentColumn.width + 20
        anchors.fill: parent

        Column {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            spacing: 10
            anchors.margins: 10
            width: 200
            Repeater {
                model: menuOpener.children.values
                delegate: Rectangle {
                    id: menuItem
                    property bool hovered: false
                    property bool pressed: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.bg1
                    radius: 5
                    width: menuBackground.width - 20
                    height: modelData.isSeperator || modelData.text == "" ? 2 : (textContent.implicitHeight + 10)

                    TextStyled {
                        id: textContent
                        anchors.centerIn: parent
                        width: menuItem.width - 10
                        text: modelData.text
                        wrapMode: Text.WordWrap
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            menuItem.hovered = true;
                        }
                        onExited: {
                            menuItem.hovered = false;
                            menuItem.pressed = false;
                        }
                        onPressed: {
                            if (!modelData.isSeperator)
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
