import QtQuick

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    implicitWidth: contentRow.implicitWidth + Styles.marginSm * 2
    radius: Styles.radiusSm
    color: Colors.background
    implicitHeight: parent.height
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Styles.marginSm
        DoubleText {
            offset: Styles.barTextOffset
            anchors.verticalCenter: parent.verticalCenter
            text: Time.time
        }
        DoubleText {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            offset: Styles.barTextOffset
        }
        DoubleText {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.date
            offset: Styles.barTextOffset
        }
    }
}
