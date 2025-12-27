import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants

PanelWindow {
    id: root
    anchors.left: true
    anchors.right: true
    height: 250

    color: "transparent"

    visible: polkitAgent.isActive

    component Spacer: Rectangle {
        Layout.preferredWidth: 500
        Layout.fillHeight: true
        color: Colors.bgDim
    }

    PolkitAgent {
        id: polkitAgent
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: root.visible
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
        Spacer {
            topRightRadius: Styles.radiusLg
            bottomRightRadius: Styles.radiusLg
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: Colors.orange
            radius: Styles.radiusLg
            ColumnLayout {
                id: contentColumn
                spacing: 12
                anchors.fill: parent
                anchors.margins: Styles.marginMd

                TextStyled {
                    Layout.fillWidth: true
                    visible: text
                    text: polkitAgent.flow?.message || null
                    font.bold: true
                    color: Colors.bgDim
                }

                TextStyled {
                    Layout.fillWidth: true
                    visible: text
                    text: polkitAgent.flow?.supplementaryMessage || null
                    color: Colors.bgDinm
                }

                TextStyled {
                    text: "Authentication failed, try again"
                    color: Colors.bgRed
                    visible: polkitAgent.flow?.failed || false
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: Colors.bg0
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
                    spacing: 8
                    ButtonStyled {
                        id: okButton
                        enabled: polkitAgent.flow && (passwordInput.text.length > 0 || !polkitAgent.flow.isResponseRequired)
                        text: "Submit"
                        radius: Styles.radiusSm
                        defaultColor: Colors.bg0
                        onClicked: {
                            if (polkitAgent.flow) {
                                polkitAgent.flow.submit(passwordInput.text);
                                passwordInput.text = "";
                                passwordInput.forceActiveFocus();
                            }
                        }
                    }
                    ButtonStyled {
                        visible: polkitAgent.isActive
                        text: "Cancel"
                        radius: Styles.radiusSm
                        defaultColor: Colors.bg0
                        onClicked: {
                            if (polkitAgent.flow) {
                                polkitAgent.flow.cancelAuthenticationRequest();
                                passwordInput.text = "";
                            }
                        }
                    }
                }
            }
        }
        Spacer {
            topLeftRadius: Styles.radiusLg
            bottomLeftRadius: Styles.radiusLg
        }
    }
}
