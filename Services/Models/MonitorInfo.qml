import QtQuick

QtObject {
    required property var modelData
    property int id: modelData.id
    property string name: modelData.name
    property string description: modelData.description
    property string make: modelData.make
    property int width: modelData.width
    property int height: modelData.height
    property real refreshRate: modelData.refreshRate
    property int transform: modelData.transform
    property int x: modelData.x
    property int y: modelData.y
    property real scale: modelData.scale
    property list<string> availableModes: modelData.availableModes
    property bool disabled: modelData.disabled
}
