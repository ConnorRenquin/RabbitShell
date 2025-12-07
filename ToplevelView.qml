import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

import qs.Constants
import qs.Components

PanelWindow {
    id: root

    property int columns: 4
    implicitWidth: toplevelGrid.count > columns ? toplevelGrid.cellWidth * columns : toplevelGrid.cellWidth * toplevelGrid.count
    implicitHeight: toplevelGrid.cellHeight * Math.ceil(toplevelGrid.count / columns)

    color: "transparent"
    visible: false

    onVisibleChanged: visible ? base.forceActiveFocus() : null

    property string keyMap: "wertyuiopasdfghjklzxcvbnm"
    property var toplevels: []

    function updateToplevels() {
        if (!Hyprland.toplevels)
            return;
        toplevels = Hyprland.toplevels.values.filter(toplevel => {
            return toplevel?.workspace?.id > 0 && toplevel?.workspace?.focused;
        });
    }

    Connections {
        target: Hyprland.toplevels
        function onValuesChanged() {
            updateToplevels();
        }
    }

    GlobalShortcut {
        name: "toplevelview"
        onPressed: {
            root.visible = !root.visible;
            updateToplevels();
        }
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
        onCleared: root.visible = false
    }

    Rectangle {
        id: base

        color: Colors.bgDim
        radius: Styles.radiusMd
        focus: true

        anchors.fill: parent

        Keys.onPressed: function (event) {
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.visible = false;
                event.accepted = true;
                return;
            }

            var pressedChar = event.text.toLowerCase();
            if (pressedChar === "")
                return;

            var index = root.keyMap.indexOf(pressedChar);

            if (index === -1 && !root.toplevels[index])
                return;

            var toplevel = root.toplevels[index].wayland;

            if (toplevel.activated) {
                root.visible = false;
                event.accepted = true;
            } else {
                toplevel.activate();
            }
        }

        GridView {
            id: toplevelGrid

            cellHeight: 100
            cellWidth: 350

            anchors.fill: parent

            model: root.toplevels
            delegate: Item {
                id: windowCard

                width: toplevelGrid.cellWidth
                height: toplevelGrid.cellHeight
                clip: true

                required property var modelData
                required property int index
                property string keyLabel: {
                    // Helper property to get the key label
                    return index < root.keyMap.length ? root.keyMap[index] : "";
                }

                ButtonStyled {
                    id: toplevelButton

                    implicitHeight: toplevelGrid.cellHeight - Styles.marginSm
                    implicitWidth: toplevelGrid.cellWidth - Styles.marginSm

                    radius: Styles.radiusMd

                    z: 1
                    anchors {
                        centerIn: parent
                    }

                    onClicked: {
                        modelData.wayland.activate();
                    }

                    IconImage {
                        id: appIcon
                        implicitHeight: 60
                        implicitWidth: 60
                        source: Quickshell.iconPath(DesktopEntries.byId(modelData.wayland?.appId)?.icon)
                        anchors {
                            top: parent.top
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            margins: Styles.marginSm
                        }
                    }

                    DoubleText {
                        id: windowTitle
                        pixelSize: 25
                        anchors {
                            top: parent.top
                            left: appIcon.right
                            right: parent.right
                            margins: Styles.marginSm
                        }
                        text: {
                            if (!windowCard.modelData.wayland)
                                return "";
                            return windowCard.modelData.wayland.title;
                        }
                        secondaryColor: Colors.bgDim
                        offset: 2
                    }

                    DoubleText {
                        id: windowShortcutAndId
                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            left: appIcon.right
                            top: windowTitle.bottom
                            margins: Styles.marginSm
                        }
                        text: {
                            if (!windowCard.keyLabel || !windowCard.modelData.wayland || !windowCard.modelData.wayland?.appId)
                                return "";
                            return windowCard.keyLabel.toUpperCase() + " | " + windowCard.modelData.wayland?.appId;
                        }
                        primaryColor: Colors.green
                        secondaryColor: Colors.bgDim
                        offset: 2
                    }
                }
            }
        }
    }

    TextStyled {
        id: noContent
        anchors.centerIn: parent
        visible: root.toplevels.length === 0
        text: "No windows on this workspace"
    }
}
