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
    property var workspaceGroups: []
    property var allToplevels: []
    property int currentIndex: -1

    function updateToplevels() {
        if (!Hyprland.toplevels)
            return;
        if (!Hyprland.focusedWorkspace)
            return;

        workspaceGroups = Hyprland.toplevels.values.reduce((groups, toplevel) => {
            var workspaceId = toplevel?.workspace?.id;
            if (workspaceId === undefined || workspaceId === null || workspaceId === Hyprland.focusedWorkspace?.id) {
                return groups;
            }
            if (!groups[workspaceId]) {
                groups[workspaceId] = [];
            }
            groups[workspaceId].push(toplevel);
            return groups;
        }, {});
        toplevels = Hyprland.toplevels.values.filter(toplevel => toplevel?.workspace?.id === Hyprland.focusedWorkspace?.id);
        allToplevels = toplevels.concat(Object.keys(workspaceGroups).sort((a, b) => parseInt(a) - parseInt(b)).map(id => workspaceGroups[id]).reduce((acc, arr) => acc.concat(arr), []));
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

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
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
        WlrLayershell.layer: WlrLayer.Overlay

        mask: Region {
            item: offMonitorBar
        }

        function getToplevelIndex(toplevel) {
            return root.allToplevels.indexOf(toplevel);
        }

        HyprlandFocusGrab {
            active: root.active
            windows: [toplevelView]
            onCleared: root.active = false
        }

        Rectangle {
            id: offMonitorBar

            visible: Object.keys(root.workspaceGroups).length > 0

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: Styles.marginLg * 2

            width: offMonitorFlow.implicitWidth + Styles.marginSm
            height: offMonitorFlow.implicitHeight + Styles.marginSm

            color: Colors.surfaceLighter
            radius: Styles.radiusMd

            GridLayoutPlus {
                id: offMonitorFlow
                anchors.centerIn: parent
                model: Object.keys(root.workspaceGroups).sort((a, b) => parseInt(a) - parseInt(b))
                delegate: ColumnLayout {
                    id: offMonitorToplevel

                    spacing: Styles.marginSm

                    Layout.alignment: Qt.AlignTop

                    required property var modelData
                    property var workspaceToplevels: root.workspaceGroups[modelData] ?? []

                    Rectangle {
                        Layout.preferredHeight: workspaceId.implicitHeight + Styles.marginSm
                        Layout.fillWidth: true
                        radius: Styles.radiusMd
                        color: Colors.surface
                        TextStyled {
                            id: workspaceId
                            anchors.fill: parent
                            font.pointSize: Styles.textSm
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: "󰜌 " + offMonitorToplevel.modelData
                        }
                    }

                    ColumnLayoutPlus {
                        model: parent.workspaceToplevels
                        delegate: ButtonStyled {
                            id: offMonitor

                            required property var modelData
                            required property int index

                            implicitWidth: 175
                            implicitHeight: 50
                            isFocused: modelData.activated

                            onClicked: modelData.wayland.activate()

                            property int globalIndex: toplevelView.getToplevelIndex(modelData)
                            property string keyLabel: globalIndex >= 0 && globalIndex < root.keyMap.length ? root.keyMap[globalIndex] : ""

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Styles.marginSm
                                IconImage {
                                    implicitHeight: 32
                                    implicitWidth: 32
                                    source: Quickshell.iconPath(DesktopEntries.byId(offMonitor.modelData.wayland?.appId)?.icon, "applications-other")
                                }
                                Rectangle {
                                    Layout.preferredHeight: text.implicitHeight
                                    Layout.preferredWidth: 30
                                    color: Colors.surfaceLighter
                                    radius: Styles.radiusLg
                                    TextStyled {
                                        id: text
                                        anchors.fill: parent
                                        text: offMonitor.keyLabel.toUpperCase()
                                        color: Colors.onSurface
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                TextStyled {
                                    Layout.fillWidth: true
                                    text: (offMonitor.modelData?.wayland?.title ?? "Unknown App")
                                    elide: Text.ElideRight
                                    font.pointSize: Styles.textSm
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: workspaceInput
            visible: false
            anchors.top: offMonitorBar.bottom
            anchors.horizontalCenter: offMonitorBar.horizontalCenter
            anchors.margins: Styles.marginSm
            color: Colors.surfaceLighter
            width: 50
            height: 50
            radius: Styles.radiusMd
            TextFieldStyled {
                id: workspaceInputField
                placeholderText: 'workspace'
                backgroundColor: Colors.surface
                anchors.fill: parent
                Keys.onEscapePressed: root.active = false;
                Keys.onReturnPressed: event => {
                    const ctrlHeld = event.modifiers & Qt.ControlModifier;
                    const shiftHeld = event.modifiers & Qt.ShiftModifier;
                    var lua;
                    if (ctrlHeld) {
                        lua = 'hl.dsp.window.move({ workspace = "' + text + '" })';
                    } else if (shiftHeld) {
                        lua = 'hl.dsp.window.move({ workspace = "' + text + '", silent = true })';
                    } else {
                        lua = 'hl.dsp.focus({ workspace = "' + text + '" })';
                    }
                    Quickshell.execDetached(["hyprctl", "dispatch", lua]);
                    root.active = false;
                }
            }
        }

        Repeater {
            model: root.toplevels.filter(toplevel => toplevel?.workspace?.id === Hyprland.focusedWorkspace?.id)
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

                color: modelData.activated ? Colors.surfaceLighter: Colors.surface
                radius: Styles.radiusMd

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    IconImage {
                        implicitHeight: 32
                        implicitWidth: 32
                        source: Quickshell.iconPath(DesktopEntries.byId(onScreen.modelData.wayland?.appId)?.icon, "applications-other")
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        TextStyled {
                            Layout.fillWidth: true
                            font.pointSize: Styles.textSm
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
                if (event.text.match(/[0-9-+]/) !== null) { // Workspace input
                    workspaceInputField.text = event.text;
                    workspaceInput.visible = true;
                    workspaceInputField.focus = true;
                    return;
                } else if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) { // Quit
                    root.active = false;
                    event.accepted = true;
                    return;
                } else { // Select a window
                    var pressedChar = event.text.toLowerCase();
                    if (pressedChar === "")
                        return;

                    var index = root.keyMap.indexOf(pressedChar);
                    if (index === -1 && !root.toplevels[index])
                        return;

                    if (index >= 0 && index < root.allToplevels.length) {
                        var toplevel = root.allToplevels[index].wayland;
                        root.active = false;
                        event.accepted = true;
                        toplevel.activate();
                    }
                }
            }
        }
    }
}
