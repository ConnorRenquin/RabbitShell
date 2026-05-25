pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

import qs.Services.Models

Singleton {
    id: root

    // Fastfetch system information
    property var systemInfo: null
    property bool isLoadingSystemInfo: false

    property Component systemInfoComponent: Component {
        SystemInfo {}
    }

    function exec(command) {
        Quickshell.execDetached(["sh", "-c", command]);
    }

    function logout() {
        exec("hyprctl dispatch 'hl.dsp.exit()'")
    }

    function suspend() {
        exec("hyprctl dispatch 'hl.dsp.global(\"quickshell:lockscreen\")' && systemctl suspend")
    }

    function reboot() {
        exec("systemctl reboot || loginctl reboot")
    }

    function shutdown() {
        exec("systemctl poweroff || loginctl poweroff")
    }

    function firmware() {
        exec("systemctl reboot --firmware-setup || loginctl reboot --firmware-setup")
    }

    // --- Fastfetch integration ---

    Process {
        id: fastfetchProcess
        command: ["fastfetch", "--json"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.isLoadingSystemInfo = false;
                try {
                    var data = JSON.parse(text);

                    // fastfetch --json outputs an array of { type, result } objects
                    var systemData = {};
                    if (Array.isArray(data)) {
                        for (var i = 0; i < data.length; i++) {
                            var module = data[i];
                            if (module.type && module.result !== undefined) {
                                systemData[module.type] = module.result;
                            }
                        }
                    }

                    var newInfo = root.systemInfoComponent.createObject(root, {
                        modelData: systemData
                    });

                    if (newInfo) {
                        var old = root.systemInfo;
                        root.systemInfo = newInfo;
                        if (old) old.destroy();
                    }
                } catch (e) {
                    console.error("System: failed to parse fastfetch data:", e);
                    root.isLoadingSystemInfo = false;
                }
            }
        }
    }

    function loadSystemInfo() {
        if (root.isLoadingSystemInfo) return;
        root.isLoadingSystemInfo = true;
        fastfetchProcess.running = true;
    }

    function refreshSystemInfo() {
        root.isLoadingSystemInfo = true;
        fastfetchProcess.running = true;
    }
}
