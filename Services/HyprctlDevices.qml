pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

Singleton {
    id: root

    property list<string> allNames: []
    property list<string> mouseNames: []
    property list<string> keyboardNames: []

    function refresh() {
        devicesProcess.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: devicesProcess
        command: ["hyprctl", "devices", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(text);
                    let all = [];
                    let mice = [];
                    let keyboards = [];

                    let miceData = data.mice || [];
                    for (let i = 0; i < miceData.length; i++) {
                        let name = String(miceData[i].name || "");
                        if (name) {
                            mice.push(name);
                            all.push(name);
                        }
                    }

                    let kbData = data.keyboards || [];
                    for (let i = 0; i < kbData.length; i++) {
                        let name = String(kbData[i].name || "");
                        if (name && all.indexOf(name) === -1) {
                            keyboards.push(name);
                            all.push(name);
                        }
                    }

                    let tabletData = data.tablets || [];
                    for (let i = 0; i < tabletData.length; i++) {
                        let name = String((tabletData[i] && tabletData[i].name) || "");
                        if (name && all.indexOf(name) === -1)
                            all.push(name);
                    }

                    root.mouseNames = mice;
                    root.keyboardNames = keyboards;
                    root.allNames = all;
                } catch (e) {
                    console.error("HyprctlDevices: Failed to parse devices:", e);
                }
            }
        }
    }
}
