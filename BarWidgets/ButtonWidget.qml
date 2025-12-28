import QtQuick

import qs.Components
import qs.Constants

ButtonStyled {
    id: root

    radius: Styles.radius0
    height: parent.height
    width: text.implicitWidth + Styles.marginMd

    property string icon: "*"
    property string command
    property string altCommand

    TextStyled {
        id: text
        text: root.icon
        anchors.centerIn: parent
    }
}
