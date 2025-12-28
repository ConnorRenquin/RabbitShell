pragma ComponentBehavior: Bound

import Quickshell.Widgets
import QtQuick
import Quickshell.Services.SystemTray

import qs.Components
import qs.Constants

BarWidget {
    id: root
    property int iconSize: 20

    implicitWidth: row.implicitWidth + Styles.marginSm * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Styles.marginSm

        Repeater {
            id: trayRow
            model: SystemTray.items

            delegate: Item {
                id: trayItem
                required property SystemTrayItem modelData
                required property int index

                property int iconSize: root.iconSize
                property bool menuOpen: false

                implicitWidth: trayItem.iconSize + Styles.marginSm
                implicitHeight: trayItem.iconSize + Styles.marginSm

                ButtonStyled {
                    id: iconButton

                    anchors.fill: parent
                    defaultColor: Colors.bg0
                    hoverColor: Colors.bg2
                    radius: Styles.radiusSm

                    scale: trayItem.menuOpen ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    IconImage {
                        id: icon
                        anchors.centerIn: parent
                        width: trayItem.iconSize
                        height: trayItem.iconSize
                        source: trayItem.modelData.icon

                        opacity: iconButton.containsMouse ? 1.0 : 0.8

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    SystemTrayMenu {
                        id: trayMenu
                        item: trayItem.modelData
                        onVisibleChanged: {
                            trayItem.menuOpen = visible;
                        }
                    }

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton && trayItem.modelData.hasMenu) {
                            trayMenu.toggleVisible();
                        } else if (mouse.button === Qt.RightButton) {
                            trayItem.modelData.activate();
                        } else if (mouse.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
