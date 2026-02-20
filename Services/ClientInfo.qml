import QtQuick

QtObject {
    required property var modelData
    property string address: modelData.address
    property list<int> at: modelData.at
    property list<int> size: modelData.size
    property int workspaceId: modelData.workspace.id
    property int monitor: modelData.monitor
}

// {
//     "address": "0x5586f85c96e0",
//     "mapped": true,
//     "hidden": false,
//     "at": [4230, 74],
//     "size": [1111, 439],
//     "workspace": {
//         "id": 2,
//         "name": "2"
//     },
//     "floating": false,
//     "pseudo": false,
//     "monitor": 1,
//     "class": "kitty",
//     "title": "hyprctl clients -j",
//     "initialClass": "kitty",
//     "initialTitle": "kitty",
//     "pid": 2998372,
//     "xwayland": false,
//     "pinned": false,
//     "fullscreen": 0,
//     "fullscreenClient": 0,
//     "grouped": [],
//     "tags": [],
//     "swallowing": "0x0",
//     "focusHistoryID": 0,
//     "inhibitingIdle": false,
//     "xdgTag": "",
//     "xdgDescription": "",
//     "contentType": "none"
// }
