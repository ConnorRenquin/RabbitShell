pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components

Loader {
    id: root

    active: false

    property bool searchAll: false

    property string keyMap: "wertyuiopasdfghjklzxcvbnm"
    property var toplevels: []

    function updateToplevels() {
        if (!Hyprland.toplevels)
            return;
        toplevels = Hyprland.toplevels.values.filter(toplevel => {
            if (root.searchAll) {
                return toplevel?.workspace?.id;
            } else {
                return toplevel?.workspace?.id > 0 && toplevel?.workspace?.focused;
            }
        });
    }

    Component.onCompleted: updateToplevels()

    Connections {
        target: Hyprland.toplevels
        function onValuesChanged() {
            root.updateToplevels();
        }
    }

    GlobalShortcut {
        name: "toplevelview"
        onPressed: {
            hideTimer.restart();
            root.updateToplevels();
            if (!root.active) {
                root.active = true;
            } else {
                Hyprland.dispatch('cyclenext');
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.active = false
    }

    sourceComponent: PanelWindow {
        id: toplevelView

        implicitWidth: base.implicitWidth
        implicitHeight: base.implicitHeight
        color: "transparent"

        HyprlandFocusGrab {
            active: root.active
            windows: [toplevelView]
            onCleared: root.active = false
        }

        Rectangle {
            id: base

            color: Colors.background
            radius: Styles.radiusMd
            focus: true

            implicitWidth: Math.max(toplevelGrid.implicitWidth, noContent.implicitWidth) + Styles.marginMd
            implicitHeight: Math.max(toplevelGrid.implicitHeight, noContent.implicitHeight) + Styles.marginMd

            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Control) {
                    root.searchAll = !root.searchAll;
                    root.updateToplevels();
                    return;
                } else if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    root.active = false;
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

                root.active = false;
                event.accepted = true;
                toplevel.activate();
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
                anchors.margins: Styles.marginSm

                columns: 4
                columnSpacing: Styles.marginSm
                rowSpacing: Styles.marginSm

                Repeater {
                    model: root.toplevels
                    delegate: ButtonStyled {
                        id: windowCard

                        required property var modelData
                        required property int index

                        Layout.preferredWidth: 340
                        Layout.preferredHeight: 80

                        radius: Styles.radiusMd
                        isFocused: modelData.activated
                        focusedColor: Colors.backgroundLifted
                        clip: true

                        property string keyLabel: index < root.keyMap.length ? root.keyMap[index] : ""

                        onClicked: modelData.wayland.activate()

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Styles.marginSm
                            IconImage {
                                id: appIcon
                                implicitHeight: 60
                                implicitWidth: 60
                                source: Quickshell.iconPath(DesktopEntries.byId(windowCard.modelData.wayland?.appId)?.icon)
                            }

                            ColumnLayout {
                                TextStyled {
                                    id: windowTitle
                                    Layout.fillWidth: true
                                    font.pixelSize: 25

                                    property string title: windowCard?.modelData?.wayland?.title ?? ""

                                    text: root.searchAll ? windowCard?.modelData?.workspace?.id + " - " + title : title
                                }

                                TextStyled {
                                    id: windowShortcutAndId
                                    Layout.fillWidth: true
                                    text: {
                                        if (!windowCard.keyLabel || !windowCard.modelData.wayland || !windowCard.modelData.wayland?.appId)
                                            return "";
                                        return windowCard.keyLabel.toUpperCase() + " | " + windowCard.modelData.wayland?.appId;
                                    }
                                    color: Colors.green
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
