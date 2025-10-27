import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30

            Row {
                anchors.centerIn: parent
                ClockWidget {}
                Repeater {
                    model: Hyprland.workspaces
                    Rectangle {
                        height: 25
                        border.width: 1
                        width: 25
                        color: Colors.bgDim
                        Text {
                            text: modelData.id
                            anchors.centerIn: parent
                            color: Colors.fg
                        }
                    }
                }
            }
        }
    }
}
