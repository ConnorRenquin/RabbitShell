import QtQuick
import QtQuick.Layouts

RowLayout {
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    Repeater {
        id: repeater
    }
}
