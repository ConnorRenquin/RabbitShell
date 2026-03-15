import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings

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

        component Spacer: Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            radius: Styles.radiusLg
            color: Colors.background
            Timer {
                repeat: true
                running: true
                interval: 1000
                onTriggered: spacerText.visible = !spacerText.visible
            }
            TextStyled {
                id: spacerText

                anchors.centerIn: parent
                text: ''
                color: Colors.backgroundError
                font.pixelSize: 160
            }
        }

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
        }

        Connections {
            target: polkitAgent.flow
            function onIsResponseRequiredChanged() {
                passwordInput.text = "";
                if (polkitAgent.flow.isResponseRequired)
                    passwordInput.forceActiveFocus();
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: Styles.marginMd
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape)
                    root.cancel();
            }
            Rectangle {
                id: passwordControls
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Colors.orange
                radius: Styles.radiusLg
                ColumnLayout {
                    id: contentColumn
                    spacing: 12
                    anchors.fill: parent
                    anchors.margins: Styles.marginMd
                    Rectangle {
                        id: polkitMonitor
                        color: Colors.background
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
                            }
                            Rectangle {
                                id: errorIndicator
                                Layout.fillHeight: true
                                Layout.preferredWidth: 20
                                radius: Styles.radiusLg
                                color: {
                                    if (polkitAgent.flow?.failed) {
                                        return "red";
                                    } else if (polkitAgent.flow?.isSuccessful) {
                                        return Colors.green;
                                    } else {
                                        return Colors.backgroundError;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: passwordArea
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: Colors.backgroundLifted
                        radius: Styles.radiusMd
                        TextFieldStyled {
                            id: passwordInput
                            echoMode: polkitAgent.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                            anchors.fill: parent
                            placeholderText: "Password"
                            anchors.margins: Styles.marginSm
                            selectByMouse: true
                            onAccepted: {
                                if (polkitAgent.flow && (passwordInput.text.length > 0 || !polkitAgent.flow.isResponseRequired)) {
                                    polkitAgent.flow.submit(passwordInput.text);
                                    passwordInput.text = "";
                                    passwordInput.forceActiveFocus();
                                }
                            }
                        }
                    }

                    RowLayout {
                        id: buttons
                        Layout.fillWidth: true
                        spacing: 8
                        ButtonStyled {
                            text: "Cancel"
                            defaultColor: Colors.backgroundError
                            onClicked: root.cancel()
                        }

                        ButtonStyled {
                            id: okButton
                            Layout.fillWidth: true
                            enabled: polkitAgent.flow && (passwordInput.text.length > 0 || !polkitAgent.flow.isResponseRequired)
                            text: "Submit"
                            defaultColor: Colors.backgroundSuccess
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
            Spacer {}
        }
    }
}
