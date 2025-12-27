pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pam

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants
import qs.Services

Scope {
    id: root

    Component.onCompleted: PatchBay.lockScreen.connect(lockScreen)

    property string wallpaperPath: ""

    function lockScreen() {
        lock.locked = true;
        swwwQueryProcess.running = true;
    }

    GlobalShortcut {
        name: 'lockscreen'
        onPressed: {
            root.lockScreen();
        }
    }

    PamContext {
        id: lockContext

        signal unlocked
        signal failed

        configDirectory: "pam"
        config: "password.conf"

        onCurrentTextChanged: showFailure = false

        onPamMessage: {
            if (this.responseRequired)
                this.respond(currentText);
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                lockContext.unlocked();
            } else {
                lockContext.currentText = "";
                lockContext.showFailure = true;
            }
            lockContext.unlockInProgress = false;
        }

        onUnlocked: lock.locked = false

        property string currentText: ""
        property bool unlockInProgress: false
        property bool showFailure: false

        function tryUnlock() {
            if (currentText !== "") {
                unlockInProgress = true;
                start();
            }
        }
    }

    Process {
        id: swwwQueryProcess
        running: true
        command: ["swww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text;
                var match = output.match(/image: ([^\s]+)/);
                if (match && match[1]) {
                    root.wallpaperPath = match[1];
                }
            }
        }
    }

    WlSessionLock {
        id: lock
        locked: false
        surface: WlSessionLockSurface {
            Rectangle {
                id: lockScreenBackground
                anchors.fill: parent
                color: Colors.bgDim

                Image {
                    id: wallpaper
                    anchors.fill: parent
                    source: root.wallpaperPath
                    fillMode: Image.PreserveAspectCrop
                }

                Rectangle {
                    id: clock
                    implicitWidth: clockText.implicitWidth + Styles.marginSm * 2
                    implicitHeight: clockText.implicitHeight
                    color: Colors.orange
                    radius: Styles.radiusMd

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: inputArea.top
                        margins: Styles.marginMd
                    }
                    TextStyled {
                        id: clockText
                        anchors.centerIn: parent
                        color: Colors.bgDim
                        font.pixelSize: 80
                        text: Time.time + '  ' + Time.date
                    }
                }

                ColumnLayout {
                    id: inputArea
                    anchors.centerIn: parent
                    implicitHeight: 40
                    RowLayout {
                        Rectangle {
                            Layout.preferredWidth: 400
                            Layout.fillHeight: true
                            color: Colors.bgDim
                            radius: Styles.radiusSm
                            TextFieldStyled { id: passwordTextField
                                anchors.fill: parent
                                anchors.centerIn: parent
                                backgroundColor: Colors.bg0
                                padding: Styles.marginSm
                                enabled: !lockContext.unlockInProgress
                                echoMode: TextInput.Password
                                inputMethodHints: Qt.ImhSensitiveData
                                placeholderText: 'Password'
                                onTextChanged: lockContext.currentText = this.text
                                onAccepted: lockContext.tryUnlock()
                                Connections {
                                    id: contextShare
                                    target: lockContext
                                    function onCurrentTextChanged() {
                                        passwordTextField.text = lockContext.currentText;
                                    }
                                }
                            }
                        }

                        ButtonStyled {
                            id: unlockButton
                            implicitWidth: unlockButtonText.implicitWidth + Styles.marginMd
                            Layout.fillHeight: true
                            radius: Styles.radiusSm
                            defaultColor: Colors.orange
                            onClicked: lockContext.tryUnlock()
                            enabled: !lockContext.unlockInProgress
                            TextStyled {
                                id: unlockButtonText
                                anchors.centerIn: parent
                                color: Colors.bgDim
                                text: ""
                            }
                        }
                    }

                    TextStyled {
                        id: failureText
                        visible: lockContext.showFailure
                        text: "Incorrect password"
                    }
                }
            }
        }
    }
}
