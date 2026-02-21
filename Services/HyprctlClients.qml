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

    Timer {
        id: hyprctrlClientsRunner
        interval: 100
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
                        var clientComponent = Qt.createComponent("ClientInfo.qml");
                        if (clientComponent.status === Component.Ready) {
                            var clientObject = clientComponent.createObject(root, {
                                modelData: clientData[i]
                            });
                            clientList.push(clientObject);
                        }
                    }
                    root.clients = clientList;
                } catch (e) {
                    console.error("Failed to parse monitor data:", e);
                }
            }
        }
    }
}
