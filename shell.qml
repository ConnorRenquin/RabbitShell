import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick

Scope {
    Bar {}
    FloatingWindow {

        Rectangle {
            // match the size of the window
            anchors.fill: parent

            radius: 5
            color: "white" // your actual color

            Column {
                anchors.centerIn: parent
                spacing: 5
                Repeater {
                    model: SystemTray.items
                    Row {
                        spacing: 20
                        IconImage {
                            implicitSize: 20
                            source: modelData.icon
                        }
                        Column {
                            Text {
                                text: modelData.title
                            }
                            Text {
                                text: modelData.tooltipTitle
                            }
                        }
                    }
                }
            }
        }
    }
}
