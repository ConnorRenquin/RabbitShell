import QtQuick

import qs.Services

SliderStyled {
    id: root

    required property AudioNodeState modelData

    onValueChanged: root.modelData.setVolume(value)
    Component.onCompleted: value = modelData.getVolume()

    Connections {
        target: root.modelData
        function onVolumeChanged() {
            root.value = root.modelData.getVolume();
        }
    }
}
