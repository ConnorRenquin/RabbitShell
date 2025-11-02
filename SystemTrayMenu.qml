import Quickshell
import QtQuick
import Quickshell.Services.SystemTray

PanelWindow {
    id: root
    property QsMenuHandle trayMenu

    focusable: true
    color: "transparent"
    implicitWidth: 200
    implicitHeight: contentColumn.height

    QsMenuOpener {
        id: menuOpener
        menu: root.trayMenu
    }

    Rectangle {
        id: menuBackground
        color: Colors.bgDim
        radius: 10
        anchors {
            fill: parent
        }

        Column {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            spacing: 10
            anchors.margins: 10
            Repeater {
                model: menuOpener.children.values
                delegate: Rectangle {
                    id: menuItem
                    property bool hovered: false
                    property bool pressed: false
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: {
                        if (pressed && !modelData.isSeperator)
                            return Qt.darker(Colors.bg0, 1.1);
                        else if (hovered && !modelData.isSeperator)
                            return Qt.lighter(Colors.bg0, 1.2);
                        else
                            return Colors.bg0;
                    }
                    radius: 5
                    width: parent.width
                    height: modelData.isSeperator || modelData.text == "" ? 2 : (textContent.implicitHeight + 10)
                    scale: pressed ? 0.95 : 1.0

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }

                    TextStyled {
                        id: textContent
                        anchors {
                            centerIn: parent
                        }
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
