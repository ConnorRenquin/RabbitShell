import QtQuick
import QtQuick.Layouts

ColumnLayout {
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    Repeater {
        id: repeater
    }
}
