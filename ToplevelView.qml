pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
import qs.Services

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
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.namespace: "toplevels"

        function getToplevelIndex(toplevel) {
            return root.toplevels.indexOf(toplevel);
        }

        HyprlandFocusGrab {
            active: root.active
            windows: [toplevelView]
            onCleared: root.active = false
        }

        // Bar for off-monitor windows
        Rectangle {
            id: offMonitorBar

            visible: offMonitorFlow.model.length > 0

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: Styles.marginLg * 2

            width: offMonitorFlow.implicitWidth + Styles.marginMd * 2
            height: offMonitorFlow.implicitHeight + Styles.marginMd

            color: Colors.background
            radius: Styles.radiusMd

            RowLayoutPlus {
                id: offMonitorFlow
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                model: root.toplevels.filter(toplevel => !toplevel?.workspace?.focused || toplevel?.workspace?.id <= 0)
                delegate: ButtonStyled {
                    id: offMonitor

                    required property var modelData
                    required property int index

                    implicitWidth: 200
                    implicitHeight: 50
                    isFocused: modelData.activated

                    onClicked: modelData.wayland.activate()

                    property int globalIndex: toplevelView.getToplevelIndex(modelData)
                    property string keyLabel: globalIndex >= 0 && globalIndex < root.keyMap.length ? root.keyMap[globalIndex] : ""

                    RowLayout {
                        anchors.fill: parent
                        IconImage {
                            implicitHeight: 24
                            implicitWidth: 24
                            source: Quickshell.iconPath(DesktopEntries.byId(offMonitor.modelData.wayland?.appId)?.icon)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 2

                            TextStyled {
                                Layout.fillWidth: true
                                font.pixelSize: Styles.textSm
                                text: offMonitor.modelData?.workspace?.id + " - " + (offMonitor.modelData?.wayland?.title ?? "")
                                elide: Text.ElideRight
                            }

                            TextStyled {
                                text: offMonitor.keyLabel.toUpperCase()
                            }
                        }
                    }
                }
            }
        }

        Repeater {
            model: root.toplevels.filter(toplevel => toplevel?.workspace?.focused && toplevel?.workspace?.id > 0)
            delegate: Rectangle {
                id: onScreen

                required property var modelData
                required property int index

                property int globalIndex: toplevelView.getToplevelIndex(modelData)
                property string keyLabel: globalIndex >= 0 && globalIndex < root.keyMap.length ? root.keyMap[globalIndex] : ""

                property ClientInfo clientInfo: HyprctlClients.clients.find(client => modelData.address === client.address.replace('0x', ''))
                property var clientMonitor: Hyprland.monitors.values.find(monitor => monitor.id === clientInfo?.monitor)

                width: 80
                height: 60

                x: clientInfo ? clientInfo.at[0] - (clientMonitor?.x ?? 0) + clientInfo.size[0] / 2 - width / 2 : 0
                y: clientInfo ? clientInfo.at[1] - (clientMonitor?.y ?? 0) + clientInfo.size[1] / 2 - height / 2 : 0

                color: Colors.background
                radius: Styles.radiusMd

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    IconImage {
                        implicitHeight: 32
                        implicitWidth: 32
                        source: Quickshell.iconPath(DesktopEntries.byId(onScreen.modelData.wayland?.appId)?.icon)
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        TextStyled {
                            Layout.fillWidth: true
                            font.pixelSize: Styles.textSm
                            text: onScreen.keyLabel.toUpperCase()
                        }
                    }
                }
            }
        }

        Rectangle {
            id: controller

            anchors.fill: parent
            color: "transparent"
            focus: true

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

                var allToplevels = root.toplevels;
                if (index >= 0 && index < allToplevels.length) {
                    var toplevel = allToplevels[index].wayland;
                    root.active = false;
                    event.accepted = true;
                    toplevel.activate();
                }
            }
        }
    }
}
