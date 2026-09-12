pragma Singleton

import Quickshell
import Quickshell.Io

import QtQuick

import qs.Components.Plus
import qs.Helpers
import qs.Services.Models

Singleton {
    id: root

    // Fastfetch system information
    property var systemInfo: null
    property bool isLoadingSystemInfo: false

    // Application launcher state
    property var filteredApplications: []
    property var applicationCategories: []
    property string applicationSearchText: ""
    property string applicationCategory: "all"
    property var applicationUsage: ({
        apps: {},
        queries: {}
    })
    property bool applicationUsageLoaded: false
    readonly property var mainApplicationCategories: [
        "AudioVideo",
        "Development",
        "Education",
        "HealthFitness",
        "Game",
        "Graphics",
        "Network",
        "Office",
        "Science",
        "Settings",
        "System",
        "Utility"
    ]
    readonly property var shellApplications: [
        {
            id: "quickshell-settings",
            name: "Settings",
            genericName: "Settings Module",
            comment: "Open the Quickshell settings module",
            keywords: ["settings", "preferences", "configuration", "config", "quickshell"],
            categories: ["Settings"],
            icon: "preferences-system",
            execute: function () {
                PatchBay.openSettings();
            }
        },
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

    FileViewPlus {
        id: applicationUsageData
        path: Qt.resolvedUrl('./.data/application-usage.json')
        defaultValue: ({
            apps: {},
            queries: {}
        })

        onDataLoaded: parsed => {
            root.applicationUsage = {
                apps: parsed.apps || {},
                queries: parsed.queries || {}
            };
            root.applicationUsageLoaded = true;
            root.updateFilteredApplications(root.applicationSearchText);
        }
    }

    function setApplicationSearchText(searchText) {
        root.applicationSearchText = searchText || "";
        root.updateFilteredApplications(root.applicationSearchText);
    }

    function setApplicationCategory(category) {
        root.applicationCategory = category || "all";
        root.updateFilteredApplications(root.applicationSearchText);
    }

    function normalizeApplicationSearchText(searchText) {
        return String(searchText || "").trim().toLowerCase().replace(/\s+/g, " ").substring(0, 64);
    }

    function applicationId(app) {
        return String(app.id || app.name || "");
    }

    function applicationStats(app) {
        return root.applicationUsage.apps[root.applicationId(app)] || {
            launches: 0,
            lastLaunched: 0
        };
    }

    function isLearnedApplication(app, searchText) {
        var queryUsage = root.applicationUsage.queries[root.normalizeApplicationSearchText(searchText)];
        if (!queryUsage)
            return false;

        return queryUsage.appId === root.applicationId(app);
    }

    function calculateApplicationRelevance(app, searchText) {
        var query = root.normalizeApplicationSearchText(searchText);
        if (query === "")
            return 1;

        var matched = false;
        var nameResult = utils.fuzzySearch(query, app.name);
        var score = nameResult.matches ? nameResult.score * 3 : 0;
        matched = matched || nameResult.matches;

        var name = String(app.name || "").toLowerCase();
        if (name === query)
            score += 200;
        else if (name.startsWith(query))
            score += 120;
        else if (name.split(/[\s._-]+/).some(word => word.startsWith(query)))
            score += 60;

        if (app.genericName) {
            var genericResult = utils.fuzzySearch(query, app.genericName);
            if (genericResult.matches) {
                score += genericResult.score * 2;
                matched = true;
            }

            if (String(app.genericName).toLowerCase().startsWith(query))
                score += 40;
        }

        if (app.comment) {
            var descResult = utils.fuzzySearch(query, app.comment);
            if (descResult.matches) {
                score += descResult.score * 1;
                matched = true;
            }
        }

        if (app.keywords) {
            var keywordsText = app.keywords.join(" ");
            var keywordsResult = utils.fuzzySearch(query, keywordsText);
            if (keywordsResult.matches) {
                score += keywordsResult.score * 1.5;
                matched = true;
            }
        }

        var isLearned = root.isLearnedApplication(app, query);
        if (!matched && !isLearned)
            return 0;

        if (isLearned)
            score += 100000;

        var stats = root.applicationStats(app);
        score += Math.log(Number(stats.launches || 0) + 1) / Math.LN2 * 3;

        return score;
    }

    function compareApplicationUsage(a, b) {
        var aStats = root.applicationStats(a);
        var bStats = root.applicationStats(b);
        var launchDifference = Number(bStats.launches || 0) - Number(aStats.launches || 0);
        if (launchDifference !== 0)
            return launchDifference;

        return Number(bStats.lastLaunched || 0) - Number(aStats.lastLaunched || 0);
    }

    function updateFilteredApplications(searchText) {
        searchText = root.normalizeApplicationSearchText(searchText);

        var allApps = root.shellApplications.concat(DesktopEntries.applications.values);

        var availableCategories = {};
        for (var i = 0; i < allApps.length; i++) {
            var categories = allApps[i].categories || [];
            for (var j = 0; j < categories.length; j++)
                availableCategories[categories[j]] = true;
        }
        root.applicationCategories = root.mainApplicationCategories.filter(category => availableCategories[category]);

        var categoryApps = allApps.filter(app => root.applicationCategory === "all" || (app.categories || []).includes(root.applicationCategory));

        if (searchText === "") {
            root.filteredApplications = categoryApps.slice().sort(root.compareApplicationUsage);
            return;
        }

        var scored = [];
        for (var k = 0; k < categoryApps.length; k++) {
            var score = root.calculateApplicationRelevance(categoryApps[k], searchText);
            if (score > 0) {
                var stats = root.applicationStats(categoryApps[k]);
                scored.push({
                    app: categoryApps[k],
                    score: score,
                    launches: Number(stats.launches || 0),
                    lastLaunched: Number(stats.lastLaunched || 0)
                });
            }
        }

        scored.sort(function (a, b) {
            if (b.score !== a.score)
                return b.score - a.score;
            if (b.launches !== a.launches)
                return b.launches - a.launches;
            return b.lastLaunched - a.lastLaunched;
        });

        var results = [];
        for (var resultIndex = 0; resultIndex < scored.length; resultIndex++) {
            results.push(scored[resultIndex].app);
        }

        root.filteredApplications = results;
    }

    function recordApplicationLaunch(app, searchText) {
        var appId = root.applicationId(app);
        if (appId === "")
            return;

        var now = Date.now();
        var apps = Object.assign({}, root.applicationUsage.apps || {});
        var previousAppUsage = apps[appId] || {};
        apps[appId] = {
            launches: Number(previousAppUsage.launches || 0) + 1,
            lastLaunched: now
        };

        var queries = Object.assign({}, root.applicationUsage.queries || {});
        var query = root.normalizeApplicationSearchText(searchText);
        if (query !== "") {
            queries[query] = {
                appId: appId,
                lastUsed: now
            };
        }

        var queryKeys = Object.keys(queries);
        if (queryKeys.length > 200) {
            queryKeys.sort((a, b) => Number(queries[b].lastUsed || 0) - Number(queries[a].lastUsed || 0));
            for (var i = 200; i < queryKeys.length; i++)
                delete queries[queryKeys[i]];
        }

        root.applicationUsage = {
            apps: apps,
            queries: queries
        };
        if (root.applicationUsageLoaded)
            applicationUsageData.save(root.applicationUsage);
    }

    function launchApplication(app) {
        if (!app)
            return;

        root.recordApplicationLaunch(app, root.applicationSearchText);
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
