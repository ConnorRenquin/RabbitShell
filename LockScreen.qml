pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants
import qs.Services

Scope {
    id: root

    function lockScreen() {
        lock.locked = true;
    }

    Component.onCompleted: PatchBay.lockScreen.connect(lockScreen)

    LockContext {
        id: lockContext
        onUnlocked: lock.locked = false
    }

    GlobalShortcut {
        name: 'lockscreen'
        onPressed: lock.locked = true
    }

    IpcHandler {
        target: 'lock'
        function lockScreen() {
            root.lockScreen()
        }
    }

    WlSessionLock {
        id: lock
        locked: false
        surface: WlSessionLockSurface {
            Rectangle {
                id: root
                anchors.fill: parent

                color: Colors.bgDim

                // // For testing
                // ButtonStyled {
                //     id: emergencyExit
                //     implicitHeight: exitText.implicitHeight
                //     implicitWidth: exitText.implicitWidth
                //     TextStyled {
                //         id: exitText
                //         text: "Its not working, let me out"
                //     }
                //     onClicked: {
                //         lockContext.unlocked();
                //     }
                // }

                Rectangle {
                    implicitWidth: clock.implicitWidth + Styles.marginSm * 2
                    implicitHeight: clock.implicitHeight
                    color: Colors.orange
                    radius: Styles.radiusMd

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: inputArea.top
                        margins: Styles.marginMd
                    }
                    TextStyled {
                        id: clock
                        anchors.centerIn: parent
                        color: Colors.bgDim
                        font.pixelSize: 80
                        text: Time.timeShort + ' - ' + Time.date
                    }
                }

                ColumnLayout {
                    id: inputArea
                    anchors.centerIn: parent
                    implicitHeight: 40
                    RowLayout {
                        TextFieldStyled {
                            id: passwordBox
                            Layout.preferredWidth: 400
                            Layout.fillHeight: true
                            backgroundColor: Colors.bg0
                            padding: Styles.marginSm
                            enabled: !lockContext.unlockInProgress
                            echoMode: TextInput.Password
                            inputMethodHints: Qt.ImhSensitiveData
                            onTextChanged: lockContext.currentText = this.text
                            onAccepted: lockContext.tryUnlock()
                            // This makes sure multiple monitors have the same text.
                            Connections {
                                target: lockContext
                                function onCurrentTextChanged() {
                                    passwordBox.text = lockContext.currentText;
                                }
                            }
                        }

                        ButtonStyled {
                            id: unlockButton
                            implicitWidth: unlockButtonText.implicitWidth + Styles.marginMd
                            Layout.fillHeight: true
                            radius: Styles.radiusSm
                            focusPolicy: Qt.NoFocus
                            enabled: !lockContext.unlockInProgress && lockContext.currentText !== ""
                            defaultColor: Colors.orange
                            onClicked: lockContext.tryUnlock()
                            TextStyled {
                                id: unlockButtonText
                                anchors.centerIn: parent
                                color: Colors.bgDim
                                text: ""
                            }
                        }
                    }

                    TextStyled {
                        visible: lockContext.showFailure
                        text: "Incorrect password"
                    }
                }
            }
        }
    }
}
