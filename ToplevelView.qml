import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Constants
import qs.Components

Loader {
    id: loader

    active: false

    GlobalShortcut {
        name: "toplevelview"
        onPressed: loader.active = !loader.active
    }

    sourceComponent: PanelWindow {
        id: root

        implicitWidth: base.implicitWidth
        implicitHeight: base.implicitHeight
        color: "transparent"

        property int columns: 4
        property string keyMap: "wertyuiopasdfghjklzxcvbnm"
        property var toplevels: []

        function updateToplevels() {
            if (!Hyprland.toplevels)
                return;
            toplevels = Hyprland.toplevels.values.filter(toplevel => {
                return toplevel?.workspace?.id > 0 && toplevel?.workspace?.focused;
            });
        }

        Component.onCompleted: updateToplevels()

        Connections {
            target: Hyprland.toplevels
            function onValuesChanged() {
                updateToplevels();
            }
        }

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        Rectangle {
            id: base

            color: Colors.bgDim
            radius: Styles.radiusMd
            focus: true

            implicitWidth: toplevelGrid.implicitWidth + Styles.marginMd
            implicitHeight: toplevelGrid.implicitHeight + Styles.marginMd

            Keys.onPressed: function (event) {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    loader.active = false;
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
                    loader.active = false;
                    event.accepted = true;
                } else {
                    toplevel.activate();
                }
            }

            TextStyled {
                id: noContent
                anchors.centerIn: parent
                visible: root.toplevels.length === 0
                text: "No windows on this workspace"
            }

            GridLayout {
                id: toplevelGrid

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Styles.marginMd / 2

                columns: root.columns
                columnSpacing: Styles.marginSm
                rowSpacing: Styles.marginSm

                Repeater {
                    model: root.toplevels
                    delegate: ButtonStyled {
                        id: windowCard

                        Layout.preferredWidth: 340
                        Layout.preferredHeight: 80

                        clip: true

                        required property var modelData
                        required property int index
                        property string keyLabel: {
                            // Helper property to get the key label
                            return index < root.keyMap.length ? root.keyMap[index] : "";
                        }

                        radius: Styles.radiusMd

                        onClicked: {
                            modelData.wayland.activate();
                        }

                        RowLayout {
                            anchors.fill: parent
                            IconImage {
                                id: appIcon
                                implicitHeight: 60
                                implicitWidth: 60
                                source: Quickshell.iconPath(DesktopEntries.byId(modelData.wayland?.appId)?.icon)
                            }

                            ColumnLayout {
                                DoubleText {
                                    id: windowTitle
                                    Layout.fillWidth: true
                                    pixelSize: 25
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
                                    Layout.fillWidth: true
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
            }
        }
    }
}
