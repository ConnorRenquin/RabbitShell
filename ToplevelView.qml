import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.Constants

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore

    width: 1200
    height: Math.min(600, grid.implicitHeight + 40)
    color: "transparent"
    visible: false

    GlobalShortcut {
        name: "toplevelview"
        onPressed: {
            root.visible = !root.visible;
        }
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
    }

    property var filteredToplevels: {
        var toplevels = Hyprland.toplevels.values;
        var result = [];
        for (var i = 0; i < toplevels.length; i++) {
            var toplevel = toplevels[i];
            if (toplevel.workspace && toplevel.workspace.focused) {
                result.push(toplevel);
            }
        }
        return result;
    }

    Rectangle {
        id: rect
        anchors.fill: parent
        anchors.margins: 10
        color: Colors.bgDim
        radius: 10
        focus: true

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                root.visible = false;
                event.accepted = true;
                return;
            }
            console.log("Key pressed:", event.key);

            // Map keys to indices
            var keyMap = "123456789abcdefghijklmnopqrstuvwxyz";
            var pressedChar = event.text.toLowerCase();
            var index = keyMap.indexOf(pressedChar);

            if (index !== -1 && index < root.filteredToplevels.length) {
                var toplevel = root.filteredToplevels[index];
                toplevel.wayland.activate();
                root.visible = false;
                event.accepted = true;
            }
        }

        onVisibleChanged: {
            if (visible)
                rect.forceActiveFocus();
        }

        GridLayout {
            id: grid
            anchors.fill: parent
            anchors.margins: 20
            columns: Math.min(4, root.filteredToplevels.length)
            columnSpacing: 15
            rowSpacing: 15

            Repeater {
                model: root.filteredToplevels

                Rectangle {
                    id: windowCard
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 180

                    color: Colors.bg0
                    radius: 8
                    border.color: Colors.green
                    border.width: 2

                    // Helper property to get the key label
                    property string keyLabel: {
                        var keyMap = "123456789abcdefghijklmnopqrstuvwxyz";
                        return index < keyMap.length ? keyMap[index] : "";
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // Thumbnail
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ScreencopyView {
                                anchors.fill: parent
                                live: false
                                captureSource: windowCard.modelData.wayland
                            }

                            // Overlay label
                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.margins: 5
                                width: labelText.width + 16
                                height: labelText.height + 12
                                color: Colors.green
                                radius: 6
                                z: 10

                                Text {
                                    id: labelText
                                    anchors.centerIn: parent
                                    text: windowCard.keyLabel
                                    color: "black"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }
                        }

                        // Title
                        Text {
                            Layout.fillWidth: true
                            text: windowCard.modelData.title || "Untitled"
                            color: Colors.fg
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14
                        }

                        // App name
                        Text {
                            Layout.fillWidth: true
                            text: windowCard.modelData.appId || ""
                            color: Colors.fgDim
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }

        // Empty state
        Text {
            anchors.centerIn: parent
            visible: root.filteredToplevels.length === 0
            text: "No windows on this workspace"
            color: Colors.fg
            font.pixelSize: 16
        }
    }
}
