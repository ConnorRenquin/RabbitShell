pragma ComponentBehavior: Bound

import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components
import qs.Services

Rectangle {
    id: root

    anchors.fill: parent
    color: Colors.backgroundLifted

    property double viewScale: 0.1
    property var selectedMonitorIndex: 0
    property MonitorInfo selectedMonitor: HyprctlMonitors?.monitors[selectedMonitorIndex] ?? null

    Connections {
        target: HyprctlMonitors
        function onMonitorsChanged() {
            root.selectedMonitor = HyprctlMonitors.monitors[root.selectedMonitorIndex];
        }
    }

    ConfirmationDialog {
        id: saveDialog
        onVisibleChanged: {
            remainingTime = totalTime;
            hideTimer.restart();
            if (saveDialog.visible) {
                HyprctlMonitors.monitors[root.selectedMonitorIndex] = root.selectedMonitor;
                HyprctlMonitors.applyAllMonitors();
            } else {
                hideTimer.stop();
            }
        }

        property int totalTime: 15
        property int remainingTime: totalTime

        title: "Apply new Configuration?"
        body: `Reverting in ${remainingTime} second${remainingTime !== 1 ? "s" : ""}`

        onAccepted: {
            hideTimer.stop();
            HyprctlMonitors.monitors[root.selectedMonitorIndex] = root.selectedMonitor;
            HyprctlMonitors.saveConfiguration();
        }

        onCanceled: Quickshell.execDetached(["bash", "-c", "hyprctl reload"])

        Timer {
            id: hideTimer
            interval: 1000
            repeat: true
            onTriggered: {
                saveDialog.remainingTime--;
                if (saveDialog.remainingTime <= 0) {
                    stop();
                    saveDialog.visible = false;
                    Quickshell.execDetached(["bash", "-c", "hyprctl reload"]);
                }
            }
        }
    }

    ColumnLayout {
        id: rootLayout

        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        Rectangle {
            id: viewToolbar

            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Colors.background
            radius: Styles.radiusSm

            RowLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                TextStyled {
                    id: viewTitle
                    text: "Display Settings"
                }

                Item {
                    Layout.fillWidth: true
                }

                ButtonStyled {
                    id: saveButton
                    text: "󰆓"
                    onClicked: saveDialog.visible = true
                }

                ButtonStyled {
                    id: reloadButton
                    text: "󰑐"
                    onClicked: {
                        HyprctlMonitors.resetConfiguration();
                        HyprctlMonitors.loadMonitors();
                        Quickshell.execDetached(["bash", "-c", "hyprctl reload"]);
                    }
                }

                ButtonStyled {
                    id: hidePanel
                    text: "󰮫"
                    onClicked: rightPanel.visible = !rightPanel.visible
                }
            }
        }

        RowLayout {
            id: mainContent

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Styles.marginSm

            Rectangle {
                id: displayPlacer
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colors.backgroundLifted
                clip: true

                ScrollView {
                    id: displayCanvas
                    anchors.fill: parent

                    TextStyled {
                        anchors.centerIn: parent
                        visible: HyprctlMonitors.monitors.length === 0
                        text: "No displays detected\nClick '󰑐' to refresh"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Repeater {
                        model: HyprctlMonitors.monitors
                        delegate: Rectangle {
                            id: monitorPositionCard

                            required property MonitorInfo modelData

                            visible: !modelData.disabled
                            x: Math.ceil(modelData.x * root.viewScale + displayCanvas.width / 2 - width / 2)
                            y: Math.ceil(modelData.y * root.viewScale + displayCanvas.height / 2 - height / 2)
                            width: parseInt(modelData.width) * root.viewScale
                            height: parseInt(modelData.height) * root.viewScale
                            color: Colors.background
                            radius: Styles.radiusSm

                            MouseArea {
                                anchors.fill: parent
                                drag.target: parent
                                drag.axis: Drag.XAxis | Drag.YAxis
                                cursorShape: Qt.OpenHandCursor
                                onPressed: cursorShape = Qt.ClosedHandCursor
                                onReleased: {
                                    cursorShape = Qt.OpenHandCursor;
                                    root.selectedMonitor.x = Math.ceil((parent.x - displayCanvas.width / 2 + parent.width / 2) / root.viewScale);
                                    root.selectedMonitor.y = Math.ceil((parent.y - displayCanvas.height / 2 + parent.height / 2) / root.viewScale);
                                }
                            }

                            Rectangle {
                                id: displayInfoTag
                                anchors.centerIn: parent
                                implicitWidth: displayInfo.width + Styles.marginSm
                                implicitHeight: displayInfo.height + Styles.marginSm
                                color: Colors.background
                                radius: Styles.radiusSm
                                Column {
                                    id: displayInfo
                                    anchors.centerIn: parent
                                    spacing: Styles.marginSm
                                    TextStyled {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: monitorPositionCard.modelData.name
                                    }
                                    TextStyled {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: monitorPositionCard.modelData.width + "x" + monitorPositionCard.modelData.height
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    id: zoomButtons
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Styles.marginMd
                    spacing: Styles.marginSm

                    ButtonStyled {
                        text: "-"
                        onClicked: {
                            if (root.viewScale > 0.05)
                                root.viewScale -= 0.05;
                        }
                    }

                    TextStyled {
                        text: `${Math.round(root.viewScale * 1000)}%`
                    }

                    ButtonStyled {
                        text: "+"
                        onClicked: {
                            if (root.viewScale < 0.5)
                                root.viewScale += 0.05;
                        }
                    }
                }
            }

            Rectangle {
                id: rightPanel
                Layout.preferredWidth: 340
                Layout.fillHeight: true
                color: Colors.background
                radius: Styles.radiusSm

                ScrollView {
                    anchors.fill: parent
                    contentWidth: availableWidth

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        TextStyled {
                            id: leftPanelTitle
                            text: "Displays"
                        }

                        GridLayoutPlus {
                            id: displaysList
                            Layout.fillWidth: true
                            model: HyprctlMonitors.monitors
                            delegate: ButtonStyled {
                                id: displayInfoCard
                                required property var modelData
                                required property int index
                                defaultColor: Colors.backgroundLifted
                                onClicked: {
                                    HyprctlMonitors.monitors[root.selectedMonitorIndex] = root.selectedMonitor;
                                    root.selectedMonitorIndex = index;
                                }
                                text: displayInfoCard.modelData.name
                            }
                        }

                        TextStyled {
                            text: root.selectedMonitor ? `${root.selectedMonitor.name} - ${root.selectedMonitor.description}` : ""
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            TextStyled {
                                text: "Enabled"
                            }
                            SwitchStyled {
                                checked: !root?.selectedMonitor?.disabled ?? false
                                onToggled: root.selectedMonitor.disabled = checked
                            }
                        }

                        TextStyled {
                            text: "Resolution"
                        }
                        RowLayout {
                            TextFieldStyled {
                                id: widthField
                                Layout.fillWidth: true
                                text: root?.selectedMonitor?.width ?? "1920"
                            }
                            TextFieldStyled {
                                id: heightField
                                Layout.fillWidth: true
                                text: root?.selectedMonitor?.height ?? "1080"
                            }
                            TextFieldStyled {
                                id: refreshRateField
                                Layout.fillWidth: true
                                text: root?.selectedMonitor?.refreshRate ?? "60"
                            }
                            ButtonStyled {
                                text: ""
                                onClicked: {
                                    root.selectedMonitor.width = parseInt(widthField.text);
                                    root.selectedMonitor.height = parseInt(heightField.text);
                                    root.selectedMonitor.refreshRate = parseFloat(refreshRateField.text);
                                }
                            }
                        }

                        RowLayout {
                            id: availableModes

                            property int resolutionWidth
                            property int resolutionHeight
                            property real refreshRate

                            ComboBoxStyled {
                                id: modesBox
                                Layout.fillWidth: true
                                model: root?.selectedMonitor?.availableModes ?? []
                                onCurrentTextChanged: root.selectedMonitor
                            }

                            ButtonStyled {
                                text: ""
                                onClicked: setMode(modesBox.currentText)
                                function setMode(mode) {
                                    var match = mode.match(/(\d+)x(\d+)@([\d.]+)Hz/);
                                    if (match) {
                                        root.selectedMonitor.width = parseInt(match[1]);
                                        root.selectedMonitor.height = parseInt(match[2]);
                                        root.selectedMonitor.refreshRate = Math.round(parseFloat(match[3]));
                                    }
                                }
                            }
                        }

                        RowLayout {
                            id: monitorScale
                            Layout.fillWidth: true

                            TextStyled {
                                text: "Scale"
                            }

                            ComboBoxStyled {
                                Layout.fillWidth: true
                                model: ["0.5", "0.75", "1.0", "1.25", "1.5", "2.0"]
                                displayText: root?.selectedMonitor?.scale ?? "1.0"
                                onCurrentTextChanged: {
                                    if (root.selectedMonitor) {
                                        root.selectedMonitor.scale = parseFloat(currentText || 1.0);
                                    }
                                }
                            }
                        }

                        RowLayout {
                            id: monitorRotation
                            Layout.fillWidth: true
                            TextStyled {
                                text: "Rotation"
                            }

                            ComboBoxStyled {
                                Layout.fillWidth: true
                                model: ["Normal", "90", "180", "270", "flipped", "flipped + 90", "flipped + 180", "flipped + 270"]
                                currentIndex: root?.selectedMonitor?.transform ?? 0
                                onCurrentValueChanged: root.selectedMonitor.transform = currentIndex ?? 0
                            }
                        }

                        ColumnLayout {
                            id: monitorPosition

                            TextStyled {
                                text: "Position"
                            }

                            RowLayout {
                                TextStyled {
                                    text: "X"
                                }
                                TextFieldStyled {
                                    id: xPosTextField
                                    text: root?.selectedMonitor?.x ?? ""
                                    Layout.fillWidth: true
                                    validator: IntValidator {}
                                    onTextChanged: root.selectedMonitor.x = parseInt(text)
                                }

                                TextStyled {
                                    text: "Y"
                                }

                                TextFieldStyled {
                                    id: yPosTextField
                                    text: root?.selectedMonitor?.y ?? ""
                                    Layout.fillWidth: true
                                    validator: IntValidator {}
                                    onTextChanged: root.selectedMonitor.y = parseInt(text)
                                }

                                ButtonStyled {
                                    text: "zero"
                                    onClicked: {
                                        root.selectedMonitor.y = 0;
                                        root.selectedMonitor.x = 0;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
