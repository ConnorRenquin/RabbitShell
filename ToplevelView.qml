import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

import qs.Constants
import qs.Components

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore

    implicitWidth: base.implicitWidth
    implicitHeight: base.implicitHeight
    color: "transparent"
    visible: false

    property string keyMap: "qwertyuiopasdfghjklzxcvbnm"

    property var toplevels: []

    function updateToplevels() {
        toplevels = Hyprland.toplevels.values.filter(toplevel => toplevel.workspace.id > 0);
    }

    Component.onCompleted: updateToplevels()

    onVisibleChanged: {
        if (visible)
            base.forceActiveFocus();
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
    }

    Rectangle {
        id: base

        color: Colors.bgDim
        radius: Styles.radiusMd
        focus: true

        implicitWidth: grid.width + Styles.marginSm
        implicitHeight: grid.height + Styles.marginSm

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
            spacing: Styles.marginSm
            columns: 4

            Repeater {
                model: root.toplevels

                // MenuCard
                delegate: Rectangle {
                    id: windowCard

                    radius: Styles.radiusSm
                    width: 400
                    height: 200
                    color: Colors.bgDim
                    clip: true

                    required property var modelData
                    required property int index
                    property string keyLabel: {
                        // Helper property to get the key label
                        return index < root.keyMap.length ? root.keyMap[index] : "";
                    }

                    Rectangle {
                        id: overlayLabel
                        z: 1

                        implicitWidth: column.width + Styles.marginMd
                        implicitHeight: column.height + Styles.marginMd

                        color: Colors.bg2
                        radius: Styles.radiusMd

                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                            margins: Styles.margin
                        }

                        Column {
                            id: column

                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: Styles.margin
                            }

                            TextStyled {
                                id: windowTitle
                                text: windowCard.modelData.wayland.title
                            }

                            TextStyled {
                                id: windowShortcutAndId
                                text: windowCard.keyLabel.toUpperCase() + " | " + windowCard.modelData.wayland.appId
                                color: Colors.green
                            }
                        }
                    }

                    // Screenshot
                    ScreencopyView {
                        id: screencopyView
                        live: true
                        width: sourceSize.width
                        height: sourceSize.height
                        captureSource: modelData.wayland
                    }
                }
            }
        }

        TextStyled {
            anchors.centerIn: parent
            visible: root.toplevels.length === 0
            text: "No windows on this workspace"
        }
    }
}
