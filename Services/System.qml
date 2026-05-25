pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

import qs.Helpers
import qs.Services.Models

Singleton {
    id: root

    // Fastfetch system information
    property var systemInfo: null
    property bool isLoadingSystemInfo: false

    // Application launcher state
    property var filteredApplications: []
    property string applicationSearchText: ""
    readonly property var shellApplications: [
        {
            name: "Settings",
            genericName: "Settings Module",
            description: "Open the Quickshell settings module",
            keywords: ["settings", "preferences", "configuration", "config", "quickshell"],
            icon: "preferences-system",
            execute: function () {
                PatchBay.openSettings();
            }
        },
        {
            name: "Text Editor",
            genericName: "Scratchpad Editor",
            description: "Open the Quickshell scratchpad text editor",
            keywords: ["text", "editor", "scratchpad", "notes", "write"],
            icon: "accessories-text-editor",
            execute: function () {
                PatchBay.openTextEditor();
            }
        },
        {
            name: "Timer",
            genericName: "Time Manager",
            description: "Open timers, stopwatch, and alarms",
            keywords: ["timer", "time", "stopwatch", "alarm", "clock"],
            icon: "alarm-symbolic",
            execute: function () {
                PatchBay.openTimer();
            }
        }
    ]

    property Component systemInfoComponent: Component {
        SystemInfo {}
    }

    Utils {
        id: utils
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

    // --- Application launcher integration ---

    Connections {
        target: DesktopEntries.applications

        function onValuesChanged() {
            root.updateFilteredApplications(root.applicationSearchText);
        }
    }

    function setApplicationSearchText(searchText) {
        root.applicationSearchText = searchText || "";
        root.updateFilteredApplications(root.applicationSearchText);
    }

    function calculateApplicationRelevance(app, searchText) {
        if (searchText === "")
            return 1;

        var nameResult = utils.fuzzySearch(searchText, app.name);
        var score = nameResult.matches ? nameResult.score * 3 : 0;

        if (app.genericName) {
            var genericResult = utils.fuzzySearch(searchText, app.genericName);
            if (genericResult.matches)
                score += genericResult.score * 2;
        }

        if (app.description) {
            var descResult = utils.fuzzySearch(searchText, app.description);
            if (descResult.matches)
                score += descResult.score * 1;
        }

        if (app.keywords) {
            var keywordsText = app.keywords.join(" ");
            var keywordsResult = utils.fuzzySearch(searchText, keywordsText);
            if (keywordsResult.matches)
                score += keywordsResult.score * 1.5;
        }

        return score;
    }

    function updateFilteredApplications(searchText) {
        searchText = searchText || "";

        var allApps = root.shellApplications.concat(DesktopEntries.applications.values);

        if (searchText === "") {
            root.filteredApplications = allApps;
            return;
        }

        var scored = [];
        for (var i = 0; i < allApps.length; i++) {
            var score = root.calculateApplicationRelevance(allApps[i], searchText);
            if (score > 0) {
                scored.push({
                    app: allApps[i],
                    score: score
                });
            }
        }

        scored.sort(function (a, b) {
            return b.score - a.score;
        });

        var results = [];
        for (var j = 0; j < scored.length; j++) {
            results.push(scored[j].app);
        }

        root.filteredApplications = results;
    }

    function launchApplication(app) {
        if (!app)
            return;

        app.execute();
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
