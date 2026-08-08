import QtQuick

QtObject {
    required property string name
    required property var value
    property list<var> options
    property string category: 'misc'
    property string editor
    property var editorOptions
}
