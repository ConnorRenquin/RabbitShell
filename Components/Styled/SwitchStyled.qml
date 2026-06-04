import QtQuick
import QtQuick.Controls

import qs.Settings

Switch {
    id: root

    property color backgroundColor: Colors.surface
    property color checkedColor: Colors.onSurface
    property color uncheckedColor: Qt.lighter(Colors.surface, Colors.lighter)
    property color handleColor: Colors.onSurface
    property color handleCheckedColor: Qt.lighter(Colors.surface, Colors.lighter)

    indicator: Rectangle {
        implicitWidth: 40
        implicitHeight: 20
        x: root.leftPadding
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: root.checked ? root.checkedColor : root.uncheckedColor

        ColorAnimation on color {
            duration: 100
        }

        Rectangle {
            x: root.checked ? parent.width - width - 2 : 2
            y: (parent.height - height) / 2
            width: parent.height - 4
            height: width
            radius: width / 2
            color: root.checked ? root.handleCheckedColor : root.handleColor

            NumberAnimation on x {
                duration: 100
            }

            ColorAnimation on color {
                duration: 100
            }
        }
    }

    contentItem: TextStyled {
        text: root.text
        opacity: enabled ? 1.0 : 0.3
        leftPadding: root.indicator.width + Styles.marginSm
        verticalAlignment: Text.AlignVCenter
        visible: root.text
    }
}
