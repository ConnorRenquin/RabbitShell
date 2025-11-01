import Quickshell
import QtQuick
import Quickshell.Services.SystemTray

PanelWindow {
    id: root
    property QsMenuHandle trayMenu

    color: "transparent"
    width: 200
    height: 400
    anchors {
        top: true
        right: true
    }

    QsMenuOpener {
        id: menuOpener
        menu: root.trayMenu
    }

    Rectangle {
        id: menuBackground
        color: Colors.bgDim
        radius: 5
        anchors {
            fill: parent
        }

        Column {
            anchors.fill: root
            spacing: 20
            Repeater {
                model: menuOpener.children.values
                Rectangle {
                    anchors {
                        fill: root
                        centerIn: menuBackground
                    }
                    color: Colors.bgDim
                    radius: 5
                    width: root.implicitWidth - 10
                    height: 25
                    Text {
                        color: Colors.fg
                        font {
                            pixelSize: 15
                        }
                        anchors {
                            centerIn: parent
                        }
                        text: modelData.text
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: event => {
                            modelData.triggered();
                        }
                    }
                }
            }
        }
    }
}
