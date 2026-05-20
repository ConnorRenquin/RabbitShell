pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

FileView {
    id: root

    blockLoading: false

    property var defaultValue: ({})

    signal dataLoaded(var data)

    function save(data) {
        root.setText(JSON.stringify(data, null, 2));
    }

    onLoaded: {
        try {
            let content = root.text();
            let parsed = content.trim() === "" ? root.defaultValue : JSON.parse(content);
            root.dataLoaded(parsed);
        } catch (e) {
            console.log("FileViewPlus: failed to parse file at", root.path, ":", e);
            root.dataLoaded(root.defaultValue);
        }
    }

    onLoadFailed: {
        console.log("FileViewPlus: file not found at", root.path, ", creating...");
        let pathStr = String(root.path).replace("file://", "");
        Quickshell.execDetached(["sh", "-c", "mkdir -p $(dirname '" + pathStr + "') && touch '" + pathStr + "'"]);
        root.save(root.defaultValue);
        root.dataLoaded(root.defaultValue);
    }
}
