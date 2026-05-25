pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Modules.SettingsMenu.SettingsViews.Components
import qs.Components

Rectangle {
    id: root

    required property string name

    color: "transparent"

    readonly property int adapterCount: Bluetooth.adapters?.values?.length ?? 0
    readonly property int deviceCount: Bluetooth.devices?.values?.length ?? 0
    readonly property int blockedDeviceCount: {
        const devices = Bluetooth.devices?.values ?? [];
        let count = 0;
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].blocked)
                count++;
        }
        return count;
    }
    readonly property int activeDeviceCount: deviceCount - blockedDeviceCount

    property var pendingPairDevice: null
    property bool blockedDevicesExpanded: false
    property bool bluetoothAgentReady: false
    property string bluetoothAgentStatus: "Starting Bluetooth pairing agent…"

    function adapterStateText(adapter) {
        return BluetoothAdapterState.toString(adapter.state);
    }

    function deviceStateText(device) {
        if (device.pairing)
            return "Pairing";

        return BluetoothDeviceState.toString(device.state);
    }

    function deviceDisplayName(device) {
        return device.name || device.deviceName || device.address || "Unknown device";
    }

    function anyAdapterDiscovering() {
        const adapters = Bluetooth.adapters?.values ?? [];
        for (let i = 0; i < adapters.length; i++) {
            if (adapters[i].discovering)
                return true;
        }

        return false;
    }

    function deviceDetailText(device) {
        const details = [];

        if (device.deviceName && device.name && device.deviceName !== device.name)
            details.push(device.deviceName);

        details.push(root.deviceStateText(device));

        if (device.blocked)
            details.push("Blocked");

        if (device.trusted)
            details.push("Trusted");

        if (device.batteryAvailable)
            details.push(`${Math.round(device.battery * 100)}% battery`);

        if (device.address)
            details.push(device.address);

        return details.join(" • ");
    }

    function prepareAdapterForPairing(device) {
        const adapter = device.adapter ?? Bluetooth.defaultAdapter;
        if (!adapter)
            return;

        if (!adapter.enabled)
            adapter.enabled = true;

        // Quickshell exposes pairable/pairableTimeout from BlueZ. Pairable is mainly
        // for incoming pair requests, but keeping it enabled avoids failing devices
        // that bounce through an incoming confirmation step during pairing.
        adapter.pairableTimeout = 0;
        adapter.pairable = true;

        // BlueZ can be flaky when a discovery session is still active during pairing.
        // The device remains in Bluetooth.devices, so stop scanning before calling pair().
        if (adapter.discovering)
            adapter.discovering = false;
    }

    function ensureBluetoothAgent() {
        if (!bluetoothctlAgent.running) {
            root.bluetoothAgentReady = false;
            root.bluetoothAgentStatus = "Starting Bluetooth pairing agent…";
            bluetoothctlAgent.running = true;
            return;
        }

        bluetoothctlAgent.write("agent KeyboardDisplay\n");
        bluetoothctlAgent.write("default-agent\n");
    }

    function handleBluetoothAgentOutput(data) {
        const line = data.trim();
        if (line.length === 0)
            return;

        const lowerLine = line.toLowerCase();
        root.bluetoothAgentStatus = line;
        if (lowerLine.includes("agent registered") || lowerLine.includes("default agent request successful") || lowerLine.includes("default agent"))
            root.bluetoothAgentReady = true;

        // bluetoothctl acts as a BlueZ pairing agent for prompts that Quickshell's
        // Bluetooth API does not currently expose. Auto-accept JustWorks/passkey
        // confirmation prompts so common headphones, mice, and controllers pair.
        if (lowerLine.includes("confirm passkey") || lowerLine.includes("authorize service") || lowerLine.includes("accept pairing"))
            bluetoothctlAgent.write("yes\n");
    }

    function pairDevice(device) {
        if (device.blocked)
            device.blocked = false;

        root.prepareAdapterForPairing(device);
        root.pendingPairDevice = device;
        root.ensureBluetoothAgent();
        pairAfterAgentTimer.restart();
    }

    Timer {
        id: pairAfterAgentTimer

        interval: 500
        repeat: false
        onTriggered: {
            if (!root.pendingPairDevice)
                return;

            root.pendingPairDevice.pair();
            root.pendingPairDevice = null;
        }
    }

    Process {
        id: bluetoothctlAgent

        command: ["bluetoothctl", "--agent", "KeyboardDisplay"]
        stdinEnabled: true
        running: true

        onStarted: {
            root.bluetoothAgentStatus = "Bluetooth pairing agent started";
            root.ensureBluetoothAgent();
        }

        onExited: function(exitCode) {
            root.bluetoothAgentReady = false;
            root.bluetoothAgentStatus = `Bluetooth pairing agent stopped (${exitCode})`;
        }

        stdout: SplitParser {
            splitMarker: ""
            onRead: function(data) {
                root.handleBluetoothAgentOutput(data);
            }
        }

        stderr: SplitParser {
            splitMarker: ""
            onRead: function(data) {
                root.handleBluetoothAgentOutput(data);
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayoutPlus {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Styles.marginSm
            spacing: Styles.marginMd

            SettingsViewTitle {
                title: root.name
                subTitle: `${root.adapterCount} adapter${root.adapterCount === 1 ? "" : "s"} • ${root.activeDeviceCount} device${root.activeDeviceCount === 1 ? "" : "s"}${root.blockedDeviceCount > 0 ? ` • ${root.blockedDeviceCount} blocked` : ""} • Agent: ${root.bluetoothAgentReady ? "ready" : root.bluetoothAgentStatus}`
            }

            SectionHeader {
                title: "Adapters"
                subtitle: "Power, scanning, discoverability, and incoming pairing"
            }

            EmptyState {
                visible: root.adapterCount === 0
                text: "No Bluetooth adapters found. Make sure BlueZ and DBus are running."
            }

            Repeater {
                model: Bluetooth.adapters

                delegate: Rectangle {
                    id: adapterCard

                    required property BluetoothAdapter modelData

                    Layout.fillWidth: true
                    implicitHeight: adapterContent.implicitHeight + Styles.marginMd
                    color: Colors.surface
                    radius: Styles.radiusMd

                    ColumnLayout {
                        id: adapterContent

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Styles.marginSm

                            SwitchStyled {
                                checked: adapterCard.modelData.enabled
                                onToggled: adapterCard.modelData.enabled = checked
                            }

                            SectionHeader {
                                title: adapterCard.modelData.name || adapterCard.modelData.adapterId || "Adapter"
                                subtitle: `${adapterCard.modelData.adapterId} • ${root.adapterStateText(adapterCard.modelData)}`
                            }

                            LoadingIndicator {
                                visible: adapterCard.modelData.discovering
                                running: visible
                            }

                            SwitchStyled {
                                enabled: adapterCard.modelData.enabled
                                text: "Scan"
                                checked: adapterCard.modelData.discovering
                                onToggled: adapterCard.modelData.discovering = checked
                            }

                            SwitchStyled {
                                enabled: adapterCard.modelData.enabled
                                text: "Discoverable"
                                checked: adapterCard.modelData.discoverable
                                onToggled: adapterCard.modelData.discoverable = checked
                            }

                            SwitchStyled {
                                enabled: adapterCard.modelData.enabled
                                text: "Pairable"
                                checked: adapterCard.modelData.pairable
                                onToggled: adapterCard.modelData.pairable = checked
                            }
                        }
                    }
                }
            }

            SectionHeader {
                title: "Devices"
                subtitle: "Pair, trust, connect, block, or forget nearby devices"
            }

            EmptyState {
                visible: root.activeDeviceCount === 0
                text: root.anyAdapterDiscovering() ? "Scanning for nearby devices…" : "No unblocked devices found. Enable scanning on an adapter to discover devices."
            }

            Repeater {
                model: Bluetooth.devices

                delegate: Rectangle {
                    id: deviceCard

                    required property BluetoothDevice modelData

                    visible: !deviceCard.modelData.blocked
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? implicitHeight : 0
                    implicitHeight: visible ? deviceContent.implicitHeight + Styles.marginMd : 0
                    color: Colors.surface
                    radius: Styles.radiusMd

                    ColumnLayout {
                        id: deviceContent

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Styles.marginSm

                            IconImage {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                source: Quickshell.iconPath(deviceCard.modelData.icon || "bluetooth", "bluetooth")
                            }

                            SectionHeader {
                                Layout.fillWidth: true
                                title: root.deviceDisplayName(deviceCard.modelData)
                                subtitle: root.deviceDetailText(deviceCard.modelData)
                            }

                            LoadingIndicator {
                                visible: deviceCard.modelData.pairing || root.deviceStateText(deviceCard.modelData) === "Connecting" || root.deviceStateText(deviceCard.modelData) === "Disconnecting"
                                running: visible
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            ButtonStyled {
                                visible: deviceCard.modelData.paired || deviceCard.modelData.bonded
                                enabled: !deviceCard.modelData.pairing && !deviceCard.modelData.blocked
                                text: deviceCard.modelData.connected ? "Disconnect" : "Connect"
                                defaultColor: deviceCard.modelData.connected ? Colors.error : Colors.background
                                textColor: deviceCard.modelData.connected ? Colors.onError : Colors.onSurface
                                onClicked: deviceCard.modelData.connected = !deviceCard.modelData.connected
                            }

                            ButtonStyled {

                                enabled: !deviceCard.modelData.connected
                                text: {
                                    if (deviceCard.modelData.pairing)
                                        return "Cancel";
                                    if (deviceCard.modelData.paired)
                                        return "Forget";
                                    return deviceCard.modelData.blocked ? "Unblock + Pair" : "Pair";
                                }
                                defaultColor: deviceCard.modelData.paired ? Colors.error : Colors.background
                                textColor: deviceCard.modelData.paired ? Colors.onError : Colors.onSurface
                                onClicked: {
                                    if (deviceCard.modelData.pairing) {
                                        deviceCard.modelData.cancelPair();
                                    } else if (deviceCard.modelData.paired) {
                                        deviceCard.modelData.forget();
                                    } else {
                                        root.pairDevice(deviceCard.modelData);
                                    }
                                }
                            }

                            ActionMenu {
                                id: extraSettingsMenu
                                text: Icons.more
                                pointSize: Styles.textLg
                                defaultColor: Colors.background
                                textColor: Colors.onSurface
                                popupWidth: extraSettingsColumn.implicitWidth + Styles.marginSm * 2
                                popupHeight: extraSettingsColumn.implicitHeight + Styles.marginSm * 2
                                popupX: -extraSettingsMenu.popupWidth / 2 + extraSettingsMenu.width / 2
                                popupY: -extraSettingsMenu.popupHeight - Styles.marginSm
                                popupColor: Colors.background
                                popupPadding: Styles.marginSm
                                onClicked: extraSettingsMenu.togglePopup()

                                ColumnLayout {
                                    id: extraSettingsColumn
                                    anchors.fill: parent
                                    spacing: Styles.marginSm

                                    SwitchStyled {
                                        text: "Trusted"
                                        checked: deviceCard.modelData.trusted
                                        onToggled: {
                                            deviceCard.modelData.trusted = checked;
                                            extraSettingsMenu.closePopup();
                                        }
                                    }
                                    SwitchStyled {
                                        text: "Blocked"
                                        checked: deviceCard.modelData.blocked
                                        onToggled: {
                                            deviceCard.modelData.blocked = checked;
                                            extraSettingsMenu.closePopup();
                                        }
                                    }
                                    SwitchStyled {
                                        text: "Wake"
                                        checked: deviceCard.modelData.wakeAllowed
                                        onToggled: {
                                            deviceCard.modelData.wakeAllowed = checked;
                                            extraSettingsMenu.closePopup();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ButtonStyled {
                visible: root.blockedDeviceCount > 0
                Layout.fillWidth: true
                textAlignment: Text.AlignLeft
                text: `${root.blockedDevicesExpanded ? "▾" : "▸"} Blocked devices`
                onClicked: root.blockedDevicesExpanded = !root.blockedDevicesExpanded
            }

            Repeater {
                model: Bluetooth.devices

                delegate: Rectangle {
                    id: blockedDeviceCard

                    required property BluetoothDevice modelData

                    visible: root.blockedDevicesExpanded && blockedDeviceCard.modelData.blocked
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? implicitHeight : 0
                    implicitHeight: visible ? blockedDeviceContent.implicitHeight + Styles.marginMd : 0
                    color: Colors.surface
                    radius: Styles.radiusMd

                    ColumnLayout {
                        id: blockedDeviceContent

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Styles.marginSm

                            IconImage {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                source: Quickshell.iconPath(blockedDeviceCard.modelData.icon || "bluetooth", "bluetooth")
                            }

                            SectionHeader {
                                title: root.deviceDisplayName(blockedDeviceCard.modelData)
                                subtitle: root.deviceDetailText(blockedDeviceCard.modelData)
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            ButtonStyled {
                                text: "Unblock"
                                onClicked: blockedDeviceCard.modelData.blocked = false
                            }
                        }
                    }
                }
            }
        }
    }

    component EmptyState: Rectangle {
        property alias text: emptyText.text

        Layout.fillWidth: true
        implicitHeight: emptyText.implicitHeight + Styles.marginMd
        color: Colors.surface
        radius: Styles.radiusMd

        TextStyled {
            id: emptyText

            anchors.fill: parent
            anchors.margins: Styles.marginSm
            color: Colors.onSurfaceVariant
            font.pointSize: Styles.textSm
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }
}
