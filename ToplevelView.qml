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
    property int currentIndex: -1

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

        currentIndex = toplevels.findIndex(toplevel => toplevel.activated);
        if (currentIndex === -1 && toplevels.length > 0) {
            currentIndex = 0;
        }
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
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.active = false
    }

    sourceComponent: PanelWindow {
        id: toplevelView

        anchors.top: true
        margins.top: Styles.marginLg * 2
        exclusionMode: ExclusionMode.Ignore
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
                hideTimer.restart();
                if (event.key === Qt.Key_Control) {
                    root.searchAll = !root.searchAll;
                    root.updateToplevels();
                    return;
                } else if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    root.active = false;
                    event.accepted = true;
                    return;
                } else if (event.key === Qt.Key_Tab) {
                    if (root.toplevels.length === 0)
                        return;
                    root.currentIndex = (root.currentIndex - 1 + root.toplevels.length) % root.toplevels.length;
                    var toplevel = root.toplevels[root.currentIndex].wayland;
                    toplevel.activate();
                    event.accepted = true;
                    return;
                } else if (event.key === Qt.Key_Alt) {
                    if (root.toplevels.length === 0)
                        return;
                    root.currentIndex = (root.currentIndex + 1) % root.toplevels.length;
                    var toplevel = root.toplevels[root.currentIndex].wayland;
                    toplevel.activate();
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

                Repeater {
                    model: root.toplevels.sort((a, b) => a.workspace.id - b.workspace.id )
                    delegate: ButtonStyled {
                        id: windowCard

                        required property var modelData
                        required property int index

                        Layout.preferredWidth: 250
                        Layout.preferredHeight: 70

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
                                implicitHeight: 32
                                implicitWidth: 32
                                source: Quickshell.iconPath(DesktopEntries.byId(windowCard.modelData.wayland?.appId)?.icon)
                            }

                            ColumnLayout {
                                TextStyled {
                                    id: windowTitle
                                    Layout.fillWidth: true
                                    font.pixelSize: Styles.textSm

                                    property string title: windowCard?.modelData?.wayland?.title ?? ""

                                    text: root.searchAll ? windowCard?.modelData?.workspace?.id + " - " + title : title
                                }

                                TextStyled {
                                    id: windowShortcutAndId
                                    Layout.fillWidth: true
                                    font.pixelSize: Styles.textSm
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
