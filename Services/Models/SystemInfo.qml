import QtQuick

QtObject {
    required property var modelData

    // Raw result objects keyed by fastfetch module type
    property var titleData:    modelData["Title"]    || null
    property var osData:       modelData["OS"]       || null
    property var hostData:     modelData["Host"]     || null
    property var kernelData:   modelData["Kernel"]   || null
    property var uptimeData:   modelData["Uptime"]   || null
    property var packagesData: modelData["Packages"] || null
    property var shellData:    modelData["Shell"]    || null
    property var wmData:       modelData["WM"]       || null
    property var wmThemeData:  modelData["WMTheme"]  || null
    property var themeData:    modelData["Theme"]    || null
    property var iconsData:    modelData["Icons"]    || null
    property var terminalData: modelData["Terminal"] || null
    property var cpuData:      modelData["CPU"]      || null
    property var gpuData:      modelData["GPU"]      || null
    property var memoryData:   modelData["Memory"]   || null
    property var diskData:     modelData["Disk"]     || null

    // Formatted convenience properties
    property string userName:    titleData?.userName  || ""
    property string hostName:    titleData?.hostName  || ""
    property string userShell:   titleData?.userShell || ""

    property string os:          osData?.prettyName  || ""
    property string hostModel:   hostData?.version   || hostData?.name || ""
    property string kernel:      kernelData ? (kernelData.name + " " + kernelData.release) : ""
    property string wm:          wmData?.prettyName  || ""
    property string terminal:    terminalData?.prettyName || ""
    property string packages:    packagesData ? String(packagesData.all) : ""

    // CPU name
    property string cpu: cpuData?.cpu || ""

    // GPU name — result is an array of GPUs
    property string gpu: {
        if (!gpuData) return "";
        var arr = Array.isArray(gpuData) ? gpuData : [gpuData];
        return arr.map(function(g) { return g.name || ""; }).filter(function(n) { return n !== ""; }).join(", ");
    }

    // Memory formatted from bytes → "X.X GB / Y.Y GB"
    property string memory: {
        if (!memoryData) return "";
        var usedGb  = Math.round(memoryData.used  / 1073741824 * 10) / 10;
        var totalGb = Math.round(memoryData.total / 1073741824 * 10) / 10;
        return usedGb + " GB / " + totalGb + " GB";
    }

    // Uptime formatted from milliseconds → "Xd Xh Xm"
    property string uptime: {
        if (!uptimeData) return "";
        var secs = Math.floor(uptimeData.uptime / 1000);
        var days  = Math.floor(secs / 86400);
        var hours = Math.floor((secs % 86400) / 3600);
        var mins  = Math.floor((secs % 3600) / 60);
        var parts = [];
        if (days  > 0) parts.push(days  + "d");
        if (hours > 0) parts.push(hours + "h");
        if (mins  > 0) parts.push(mins  + "m");
        return parts.length > 0 ? parts.join(" ") : "< 1m";
    }

    // Full raw data for any extra access
    property var rawData: modelData
}
