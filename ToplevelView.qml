import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

import qs.Constants
import qs.Components

PanelWindow {
    id: root

    implicitWidth: toplevels.length > 0 ? base.implicitWidth : noContent.implicitWidth + Styles.marginSm
    implicitHeight: toplevels.length > 0 ? base.implicitHeight : noContent.implicitHeight + Styles.marginSm
    color: "transparent"
    visible: false

    onVisibleChanged: visible ? base.forceActiveFocus() : null

    property string keyMap: "wertyuiopasdfghjklzxcvbnm"
    property var toplevels: []

    function updateToplevels() {
        if (!Hyprland.toplevels)
            return;
        toplevels = Hyprland.toplevels.values.filter(toplevel => {
            if (!toplevel || !toplevel.workspace || !toplevel.workspace.id)
                return false;
            return toplevel.workspace.id > 0;
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

        implicitWidth: root.toplevels.length > 0 ? grid.width + Styles.marginSm : noContent.implicitWidth + Styles.marginSm
        implicitHeight: root.toplevels.length > 0 ? grid.height + Styles.marginSm : noContent.implicitHeight + Styles.marginSm

        anchors.centerIn: parent

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

        Grid {
            id: grid
            anchors.centerIn: parent
            spacing: Styles.marginSm
            columns: 3

            Repeater {
                model: root.toplevels
                delegate: Rectangle {
                    id: windowCard

                    width: 400
                    height: 200
                    radius: Styles.radiusSm
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

                        implicitWidth: windowContent.width + Styles.marginMd
                        implicitHeight: windowContent.height + Styles.marginMd

                        color: Colors.bg2
                        radius: Styles.radiusMd

                        z: 1
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                            margins: Styles.margin
                        }

                        Column {
                            id: windowContent

                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: Styles.margin
                            }

                            DoubleText {
                                id: windowTitle
                                text: {
                                    if (!windowCard.modelData.wayland)
                                        return "";
                                    return windowCard.modelData.wayland.title;
                                }
                                secondaryColor: Colors.bgDim
                                offset: 2
                            }

                            // TextStyled {
                            DoubleText {
                                id: windowShortcutAndId
                                text: {
                                    if (!windowCard.keyLabel || !windowCard.modelData.wayland || !windowCard.modelData.wayland.appId)
                                        return "";
                                    return windowCard.keyLabel.toUpperCase() + " | " + windowCard.modelData.wayland.appId;
                                }
                                primaryColor: Colors.green
                                secondaryColor: Colors.bgDim
                                offset: 2
                            }
                        }
                    }

                    ScreencopyView {
                        id: windowPreview
                        live: true
                        width: sourceSize.width
                        height: sourceSize.height
                        captureSource: modelData.wayland

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            implicitWidth: appIcon.implicitWidth + Styles.marginSm
                            implicitHeight: appIcon.implicitHeight + Styles.marginSm
                            radius: Styles.radiusSm
                            color: Colors.bg3
                            anchors.margins: Styles.marginSm
                            IconImage {
                                id: appIcon
                                anchors.centerIn: parent
                                implicitHeight: 40
                                implicitWidth: 40
                                source: Quickshell.iconPath(DesktopEntries.byId(modelData.wayland.appId).icon)
                            }
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
}
