import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.Constants
import qs.Components

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore

    implicitWidth: rect.implicitWidth
    implicitHeight: rect.implicitHeight
    color: "transparent"
    visible: false

    GlobalShortcut {
        name: "toplevelview"
        onPressed: root.visible = !root.visible
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
    }

    property var toplevels: Hyprland.toplevels.values.filter(toplevel => toplevel.workspace.id > 0)
    property string keyMap: "qwertyuiopasdfghjklzxcvbnm"

    onVisibleChanged: {
        if (visible)
            rect.forceActiveFocus();
    }

    Rectangle {
        id: rect

        color: Colors.bgDim
        radius: Styles.radiusSm
        focus: true

        implicitWidth: grid.width + 20
        implicitHeight: grid.height + 20

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
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

        Grid {
            id: grid
            anchors.centerIn: parent
            spacing: 10
            columns: 4

            Repeater {
                model: root.toplevels

                // MenuCard
                delegate: Rectangle {
                    id: windowCard
                    required property var modelData
                    required property int index

                    radius: Styles.radiusSm
                    width: 400
                    height: 200
                    color: Colors.bgDim
                    clip: true

                    // Helper property to get the key label
                    property string keyLabel: {
                        return index < root.keyMap.length ? root.keyMap[index] : "";
                    }

                    // Overlay label
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Styles.margin
                        implicitWidth: column.width + Styles.margin
                        implicitHeight: column.height + Styles.margin
                        color: Colors.bg2
                        radius: 6
                        z: 10

                        Column {
                            id: column
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: Styles.margin
                            }
                            TextStyled {
                                id: labelText
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }
                                text: windowCard.modelData.wayland.title
                                color: Colors.fg
                            }
                            TextStyled {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }
                                text: windowCard.keyLabel.toUpperCase() + " | " + windowCard.modelData.wayland.appId
                                color: Colors.green
                                font.pixelSize: 14
                            }
                        }
                    }

                    ScreencopyView {
                        id: screencopyView
                        live: true
                        anchors.centerIn: parent
                        width: sourceSize.width
                        height: sourceSize.height
                        captureSource: modelData.wayland
                    }
                }
            }
        }

        // Empty state
        Text {
            anchors.centerIn: parent
            visible: root.toplevels.length === 0
            text: "No windows on this workspace"
            color: Colors.fg
            font.pixelSize: 16
        }
    }
}
