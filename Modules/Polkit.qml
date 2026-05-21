pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Loader {
    id: loader

    active: polkitAgent.isActive

    PolkitAgent {
        id: polkitAgent
    }

    sourceComponent: PanelWindow {
        id: root

        implicitHeight: 250
        implicitWidth: 1500

        color: "transparent"

        function cancel() {
            if (polkitAgent.flow) {
                polkitAgent.flow.cancelAuthenticationRequest();
                passwordInput.text = "";
            }
        }

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
        }

        Connections {
            target: polkitAgent.flow
            function onFailedChanged() {
                if (polkitAgent.flow?.failed) {
                    SoundEffects.playError();
                }
            }
            function onIsCompletedChanged() {
                if (polkitAgent.flow?.isCompleted) {
                    SoundEffects.playNotification();
                }
            }
            function onIsResponseRequiredChanged() {
                passwordInput.text = "";
                if (polkitAgent.flow.isResponseRequired) {
                    passwordInput.forceActiveFocus();
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: Styles.marginMd
            Controls {
                id: controls
            }
            Keys.onPressed: event => {
                if (controls.escapePressed(event))
                    root.cancel();
            }
            Rectangle {
                id: passwordControls
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Colors.onError
                radius: Styles.radiusLg
                ColumnLayout {
                    id: contentColumn
                    spacing: 12
                    anchors.fill: parent
                    anchors.margins: Styles.marginMd
                    Rectangle {
                        id: polkitMonitor
                        color: Colors.surface
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        radius: Styles.radiusMd
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Styles.marginSm
                            TextStyled {
                                id: polkitMessage
                                Layout.fillWidth: true
                                text: polkitAgent.flow?.message || null
                                wrapMode: Text.WordWrap
                            }
                            Rectangle {
                                id: errorIndicator
                                Layout.fillHeight: true
                                Layout.preferredWidth: 20
                                radius: Styles.radiusLg
                                color: {
                                    if (polkitAgent.flow?.failed) {
                                        incorrectText.visible = true;
                                        return "red";
                                    } else if (polkitAgent.flow?.isSuccessful) {
                                        return Colors.primary;
                                    } else {
                                        return Colors.errorDarker;
                                    }
                                    incorrectText.visible = false;
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: passwordArea
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: Colors.background
                        radius: Styles.radiusMd
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Styles.marginXS
                            TextFieldStyled {
                                id: passwordInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                echoMode: polkitAgent.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                                placeholderText: "Password"
                                selectByMouse: true
                                onAccepted: {
                                    if (polkitAgent.flow && (passwordInput.text.length > 0 || !polkitAgent.flow.isResponseRequired)) {
                                        polkitAgent.flow.submit(passwordInput.text);
                                        passwordInput.text = "";
                                        passwordInput.forceActiveFocus();
                                    }
                                }
                            }
                            TextStyled {
                                id: incorrectText
                                Layout.preferredWidth: implicitWidth + Styles.marginSm
                                visible: false
                                text: '  INCORRECT  '
                            }
                        }
                    }

                    RowLayout {
                        id: buttons
                        Layout.fillWidth: true
                        spacing: 8
                        ButtonStyled {
                            text: "Cancel"
                            onClicked: root.cancel()
                        }

                        ButtonStyled {
                            id: okButton
                            Layout.fillWidth: true
                            enabled: polkitAgent.flow && (passwordInput.text.length > 0 || !polkitAgent.flow.isResponseRequired)
                            text: "Submit"
                            onClicked: {
                                if (polkitAgent.flow) {
                                    polkitAgent.flow.submit(passwordInput.text);
                                    passwordInput.text = "";
                                    passwordInput.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                radius: Styles.radiusLg
                color: Colors.onError
                Timer {
                    repeat: true
                    running: true
                    interval: 1000
                    onTriggered: spacerText.visible = !spacerText.visible
                }
                TextStyled {
                    id: spacerText
                    anchors.centerIn: parent
                    text: Icons.warning
                    color: Colors.error
                    font.pointSize: 160
                }
            }
        }
    }
}
