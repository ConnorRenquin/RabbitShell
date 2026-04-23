import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components

Rectangle {
    color: Colors.surfaceContainer
    ScrollView {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        contentWidth: availableWidth

        ColumnLayoutPlus {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Colors.surface
                radius: Styles.radiusLg

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    TextStyled {
                        text: "Bluetooth"
                    }
                }
            }
            TextStyled {
                text: "Adapters"
            }
            Repeater {
                model: Bluetooth.adapters
                delegate: RowLayout {
                    id: adapterControl
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    required property BluetoothAdapter modelData
                    SwitchStyled {
                        checked: adapterControl?.modelData?.enabled ?? false
                        onToggled: adapterControl.modelData.enabled = checked
                    }
                    TextStyled {
                        text: adapterControl.modelData.name
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    LoadingIndicator {
                        visible: adapterControl.modelData.discovering
                    }
                    SwitchStyled {
                        checked: adapterControl?.modelData?.discovering ?? false
                        onToggled: adapterControl.modelData.discovering = checked
                    }
                }
            }
            TextStyled {
                text: "Devices"
            }
            TextStyled {
                visible: Bluetooth?.devices?.values?.length <= 0
                text: "No devices currently found."
                font.pixelSize: Styles.textSm
            }
            Repeater {
                model: Bluetooth.devices
                delegate: RowLayout {
                    id: deviceCard
                    required property BluetoothDevice modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    IconImage {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        source: Quickshell.iconPath(deviceCard.modelData.icon, "bluetooth")
                    }
                    TextStyled {
                        id: deviceInfo
                        text: {
                            if (deviceCard.modelData.deviceName) {
                                return deviceCard.modelData.deviceName;
                            } else {
                                return deviceCard?.modelData?.name;
                            }
                        }
                    }
                    RowSpacer {}
                    ButtonStyled {
                        id: connectDisconnect
                        visible: deviceCard.modelData.bonded
                        text: {
                            if (deviceCard.modelData.connected) {
                                return "disconnect";
                            } else {
                                return "connect";
                            }
                        }
                        onClicked: {
                            if (deviceCard.modelData.connected) {
                                deviceCard.modelData.disconnect();
                            } else {
                                deviceCard.modelData.connect();
                            }
                        }
                    }

                    ButtonStyled {
                        text: {
                            if (deviceCard.modelData.pairing) {
                                return "cancel";
                            } else if (deviceCard.modelData.paired) {
                                return "paired";
                            } else {
                                return "pair";
                            }
                        }
                        onClicked: {
                            if (deviceCard.modelData.pairing) {
                                onClicked: deviceCard.modelData.cancelPair();
                            } else if (deviceCard.modelData.paired) {
                                onClicked: deviceCard.modelData.forget();
                            } else {
                                deviceCard.modelData.pair();
                            }
                        }
                    }
                }
            }
        }
    }
}
