import QtQuick

QtObject {
    required property var modelData
    property string address: modelData.address
    property list<int> at: modelData.at
    property list<int> size: modelData.size
    property int workspaceId: modelData.workspace.id
    property int monitor: modelData.monitor
}
