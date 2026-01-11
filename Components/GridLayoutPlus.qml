import QtQuick
import QtQuick.Layouts

GridLayout {
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    Repeater {
        id: repeater
    }
}
