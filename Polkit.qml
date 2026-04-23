pragma ComponentBehavior: Bound
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
            color: Colors.surface
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
                color: Colors.errorDarker
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
                color: Colors.error
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
                                        return Colors.primary;
                                    } else {
                                        return Colors.errorDarker;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: passwordArea
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: Colors.surfaceContainer
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
                            defaultColor: Colors.errorDarker
                            onClicked: root.cancel()
                        }

                        ButtonStyled {
                            id: okButton
                            Layout.fillWidth: true
                            enabled: polkitAgent.flow && (passwordInput.text.length > 0 || !polkitAgent.flow.isResponseRequired)
                            text: "Submit"
                            defaultColor: Colors.primaryDarker
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
