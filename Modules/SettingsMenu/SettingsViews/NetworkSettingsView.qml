pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Networking

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Modules.SettingsMenu.SettingsViews.Components
import qs.Components

Rectangle {
    id: root

    color: "transparent"

    property string manualStatus: ""

    function runNmcli(args) {
        Quickshell.execDetached(["nmcli"].concat(args));
    }

    function editConnection(currentName, newName, password, autoconnect) {
        const trimmedCurrentName = currentName.trim();
        const trimmedNewName = newName.trim();

        if (trimmedCurrentName.length === 0) {
            root.manualStatus = "Connection name is required.";
            return;
        }

        const args = ["connection", "modify", "id", trimmedCurrentName, "connection.autoconnect", autoconnect ? "yes" : "no"];
        if (trimmedNewName.length > 0 && trimmedNewName !== trimmedCurrentName) {
            args.push("connection.id", trimmedNewName);
        }
        if (password.length > 0) {
            args.push("wifi-sec.key-mgmt", "wpa-psk", "wifi-sec.psk", password);
        }

        root.manualStatus = "Updating " + trimmedCurrentName + "...";
        root.runNmcli(args);
    }

    function addManualWifi(ssid, password, ifname, secure, connectNow) {
        const trimmedSsid = ssid.trim();
        const trimmedIfname = ifname.trim();

        if (trimmedSsid.length === 0) {
            root.manualStatus = "SSID is required.";
            return;
        }

        const iface = trimmedIfname.length > 0 ? trimmedIfname : "*";
        const args = ["connection", "add", "type", "wifi", "ifname", iface, "con-name", trimmedSsid, "ssid", trimmedSsid, "connection.autoconnect", "yes"];

        if (secure) {
            if (password.length === 0) {
                root.manualStatus = "Password is required for secured Wi-Fi.";
                return;
            }

            args.push("wifi-sec.key-mgmt", "wpa-psk", "wifi-sec.psk", password);
        }

        root.manualStatus = connectNow ? "Adding and connecting to " + trimmedSsid + "..." : "Adding " + trimmedSsid + "...";
        root.runNmcli(args);
        if (connectNow) {
            root.runNmcli(["connection", "up", "id", trimmedSsid]);
        }
    }

    function connectManualWifi(ssid, password, ifname, hidden) {
        const trimmedSsid = ssid.trim();
        const trimmedIfname = ifname.trim();

        if (trimmedSsid.length === 0) {
            root.manualStatus = "SSID is required.";
            return;
        }

        const args = ["device", "wifi", "connect", trimmedSsid];
        if (password.length > 0) {
            args.push("password", password);
        }
        if (trimmedIfname.length > 0) {
            args.push("ifname", trimmedIfname);
        }
        if (hidden) {
            args.push("hidden", "yes");
        }

        root.manualStatus = "Connecting to " + trimmedSsid + "...";
        root.runNmcli(args);
    }

    function isWifiDevice(device) {
        return device?.type === DeviceType.Wifi;
    }

    function isWiredDevice(device) {
        return device?.type === DeviceType.Wired;
    }

    function networkSecurityText(network) {
        if (!network || network.security === undefined) {
            return "";
        }

        return WifiSecurityType.toString(network.security);
    }

    function networkNeedsPassword(network) {
        if (!network || network.security === undefined) {
            return false;
        }

        return !network.known && network.security !== WifiSecurityType.Open;
    }

    function signalIcon(strength) {
        if (strength >= 0.75)
            return "󰤨";
        if (strength >= 0.5)
            return "󰤥";
        if (strength >= 0.25)
            return "󰤢";
        return "󰤟";
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        contentWidth: availableWidth

        ColumnLayoutPlus {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            SettingsViewTitle {
                title: "Network"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: connectivity.implicitHeight + Styles.marginSm * 2
                color: Colors.surface
                radius: Styles.radiusLg

                RowLayout {
                    id: connectivity
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm
                    spacing: Styles.marginSm

                    SectionHeader {
                        title: "Connectivity"
                        subtitle: NetworkConnectivity.toString(Networking.connectivity)
                    }

                    ButtonStyled {
                        visible: Networking.canCheckConnectivity
                        text: "check"
                        onClicked: Networking.checkConnectivity()
                    }
                    SwitchStyled {
                        checked: Networking.wifiEnabled
                        enabled: Networking.wifiHardwareEnabled
                        onToggled: Networking.wifiEnabled = checked
                    }

                    TextStyled {
                        text: Networking.wifiHardwareEnabled ? "Wi-Fi" : "Wi-Fi hardware disabled"
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                TextStyled {
                    text: "Manual Wi-Fi Connection"
                    font.pointSize: Styles.textLg
                }

                TextStyled {
                    text: "Add or connect to hidden/non-broadcast networks. Interface can be left blank to let NetworkManager choose."
                    font.pointSize: Styles.textSm
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.marginSm

                    TextFieldStyled {
                        id: manualSsid

                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        placeholderText: "SSID"
                    }

                    TextFieldStyled {
                        id: manualIfname

                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 35
                        placeholderText: "Interface"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.marginSm

                    TextFieldStyled {
                        id: manualPassword

                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        echoMode: TextInput.Password
                        placeholderText: manualSecure.checked ? "Password" : "Password (optional)"
                        onAccepted: root.connectManualWifi(manualSsid.text, text, manualIfname.text, manualHidden.checked)
                    }

                    SwitchStyled {
                        id: manualSecure

                        text: "secured"
                        checked: true
                    }

                    SwitchStyled {
                        id: manualHidden

                        text: "hidden"
                        checked: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.marginSm

                    ButtonStyled {
                        text: "connect"
                        onClicked: root.connectManualWifi(manualSsid.text, manualPassword.text, manualIfname.text, manualHidden.checked)
                    }

                    ButtonStyled {
                        text: "add"
                        onClicked: root.addManualWifi(manualSsid.text, manualPassword.text, manualIfname.text, manualSecure.checked, false)
                    }

                    ButtonStyled {
                        text: "add + connect"
                        onClicked: root.connectManualWifi(manualSsid.text, manualPassword.text, manualIfname.text, manualHidden.checked)
                    }
                }

                TextStyled {
                    visible: root.manualStatus.length > 0
                    text: root.manualStatus
                    font.pointSize: Styles.textSm
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            TextStyled {
                text: "Devices"
                font.pointSize: Styles.textLg
            }

            Repeater {
                model: Networking.devices

                delegate: Rectangle {
                    id: deviceCard

                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: deviceColumn.implicitHeight + Styles.marginMd
                    color: Colors.surface
                    radius: Styles.radiusLg

                    ColumnLayout {
                        id: deviceColumn

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Styles.marginSm

                            TextStyled {
                                text: root.isWifiDevice(deviceCard.modelData) ? "󰤨" : "󰈀"
                                font.pointSize: Styles.textLg
                            }

                            SectionHeader {
                                title: deviceCard.modelData.name || DeviceType.toString(deviceCard.modelData.type)
                                subtitle: `${DeviceType.toString(deviceCard.modelData.type)} • ${ConnectionState.toString(deviceCard.modelData.state)}${deviceCard.modelData.address ? " • " + deviceCard.modelData.address : ""}`
                            }

                            ButtonStyled {
                                visible: deviceCard.modelData.connected
                                text: "disconnect"
                                onClicked: deviceCard.modelData.disconnect()
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: deviceCard.modelData.nmManaged !== undefined || deviceCard.modelData.autoconnect !== undefined
                            spacing: Styles.marginMd

                            SwitchStyled {
                                visible: deviceCard.modelData.nmManaged !== undefined
                                text: "managed"
                                checked: deviceCard.modelData.nmManaged ?? false
                                onToggled: deviceCard.modelData.nmManaged = checked
                            }

                            SwitchStyled {
                                visible: deviceCard.modelData.autoconnect !== undefined
                                text: "autoconnect"
                                checked: deviceCard.modelData.autoconnect ?? false
                                onToggled: deviceCard.modelData.autoconnect = checked
                            }

                            SwitchStyled {
                                text: "scan"
                                checked: deviceCard.modelData.scannerEnabled ?? false
                                visible: root.isWifiDevice(deviceCard.modelData)
                                onToggled: deviceCard.modelData.scannerEnabled = checked
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.isWifiDevice(deviceCard.modelData)
                            spacing: Styles.marginSm

                            TextStyled {
                                text: "Wi-Fi Networks"
                            }

                            Repeater {
                                model: deviceCard.modelData.networks

                                delegate: Rectangle {
                                    id: networkCard

                                    required property var modelData
                                    property bool passwordVisible: false
                                    property bool editVisible: false
                                    property string errorText: ""

                                    Layout.fillWidth: true
                                    implicitHeight: networkColumn.implicitHeight + Styles.marginSm * 2
                                    color: Qt.lighter(Colors.surface, Colors.lighter)
                                    radius: Styles.radiusMd

                                    Connections {
                                        target: networkCard.modelData

                                        function onConnectionFailed(reason) {
                                            networkCard.errorText = ConnectionFailReason.toString(reason);
                                            networkCard.passwordVisible = root.networkNeedsPassword(networkCard.modelData);
                                        }
                                    }

                                    ColumnLayout {
                                        id: networkColumn

                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: Styles.marginSm
                                        spacing: Styles.marginSm

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Styles.marginSm

                                            TextStyled {
                                                text: root.signalIcon(networkCard.modelData.signalStrength ?? 0)
                                            }

                                            SectionHeader {
                                                title: networkCard.modelData.name || "Hidden network"
                                                subtitle: `${ConnectionState.toString(networkCard.modelData.state)} • ${Math.round((networkCard.modelData.signalStrength ?? 0) * 100)}% • ${root.networkSecurityText(networkCard.modelData)}${networkCard.modelData.known ? " • known" : ""}`
                                            }

                                            LoadingIndicator {
                                                visible: networkCard.modelData.stateChanging
                                            }

                                            ButtonStyled {
                                                text: networkCard.modelData.connected ? "disconnect" : "connect"
                                                onClicked: {
                                                    networkCard.errorText = "";
                                                    if (networkCard.modelData.connected) {
                                                        networkCard.modelData.disconnect();
                                                    } else if (root.networkNeedsPassword(networkCard.modelData)) {
                                                        networkCard.passwordVisible = !networkCard.passwordVisible;
                                                    } else {
                                                        networkCard.modelData.connect();
                                                    }
                                                }
                                            }

                                            ButtonStyled {
                                                visible: networkCard.modelData.known
                                                text: networkCard.editVisible ? "close" : "edit"
                                                onClicked: networkCard.editVisible = !networkCard.editVisible
                                            }

                                            ButtonStyled {
                                                visible: networkCard.modelData.known && !networkCard.modelData.connected
                                                text: "forget"
                                                onClicked: networkCard.modelData.forget()
                                            }
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            visible: networkCard.editVisible
                                            spacing: Styles.marginSm

                                            TextFieldStyled {
                                                id: editNameField

                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 35
                                                text: networkCard.modelData.name
                                                placeholderText: "Connection name"
                                            }

                                            TextFieldStyled {
                                                id: editPasswordField

                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 35
                                                echoMode: TextInput.Password
                                                placeholderText: "New password (leave blank to keep)"
                                            }

                                            SwitchStyled {
                                                id: editAutoconnect

                                                text: "autoconnect"
                                                checked: true
                                            }

                                            ButtonStyled {
                                                text: "save"
                                                onClicked: {
                                                    root.editConnection(networkCard.modelData.name, editNameField.text, editPasswordField.text, editAutoconnect.checked);
                                                    editPasswordField.text = "";
                                                    networkCard.editVisible = false;
                                                }
                                            }
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            visible: networkCard.passwordVisible
                                            spacing: Styles.marginSm

                                            TextFieldStyled {
                                                id: passwordField

                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 35
                                                echoMode: TextInput.Password
                                                placeholderText: "Password"
                                                onAccepted: {
                                                    networkCard.modelData.connectWithPsk(text);
                                                    text = "";
                                                    networkCard.passwordVisible = false;
                                                }
                                            }

                                            ButtonStyled {
                                                text: "join"
                                                onClicked: {
                                                    networkCard.modelData.connectWithPsk(passwordField.text);
                                                    passwordField.text = "";
                                                    networkCard.passwordVisible = false;
                                                }
                                            }
                                        }

                                        TextStyled {
                                            visible: networkCard.errorText.length > 0
                                            text: `Connection failed: ${networkCard.errorText}`
                                            font.pointSize: Styles.textSm
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
}
