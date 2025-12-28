import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants

PanelWindow {
    id: root

    implicitHeight: 250
    implicitWidth: 1500

    color: "transparent"

    visible: polkitAgent.isActive

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
        color: Colors.bgDim
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
            color: Colors.bgRed
            font.pixelSize: 160
        }
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
                    color: Colors.bgDim
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
                                if( polkitAgent.flow?.failed) {
                                    return   "red"
                                } else if (polkitAgent.flow?.isSuccessful){
                                    console.log('hi')
                                    return Colors.green
                                } else {
                                    return Colors.bgRed
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: passwordArea
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
                    id: buttons
                    Layout.fillWidth: true
                    spacing: 8
                    ButtonStyled {
                        text: "Cancel"
                        radius: Styles.radiusSm
                        defaultColor: Colors.bgRed
                        onClicked: root.cancel()
                    }

                    ButtonStyled {
                        id: okButton
                        Layout.fillWidth: true
                        enabled: polkitAgent.flow && (passwordInput.text.length > 0 || !polkitAgent.flow.isResponseRequired)
                        text: "Submit"
                        radius: Styles.radiusSm
                        defaultColor: Colors.bgGreen
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
