pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    property alias watch: hyprctrlClientsRunner.repeat
    property list<ClientInfo> clients

    function init() {
        console.log('HyprctlClients -----------------------------------------');
    }

    property Component clientInfoComponent: Component {
        ClientInfo {}
    }

    function destroyOldClients() {
        for (var i = 0; i < root.clients.length; i++) {
            if (root.clients[i]) {
                root.clients[i].destroy();
            }
        }
    }

    Timer {
        id: hyprctrlClientsRunner
        interval: 500  // Reduced frequency - 100ms was excessive
        running: true
        repeat: true
        onTriggered: hyprctlClients.running = true
    }

    Process {
        id: hyprctlClients
        running: true
        command: ['sh', '-c', 'hyprctl clients -j']
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var clientData = JSON.parse(this.text);
                    var clientList = [];

                    for (var i = 0; i < clientData.length; i++) {
                        var clientObject = root.clientInfoComponent.createObject(root, {
                            modelData: clientData[i]
                        });
                        if (clientObject) {
                            clientList.push(clientObject);
                        }
                    }

                    root.destroyOldClients();
                    root.clients = clientList;
                } catch (e) {
                    console.error("Failed to parse client data:", e);
                }
            }
        }
    }
}