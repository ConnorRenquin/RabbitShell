import QtQuick

import qs.Components
import qs.Constants
import qs.Services

Rectangle {
    implicitWidth: contentRow.implicitWidth + Styles.margin * 2
    radius: Styles.radiusSm
    color: Colors.background
    implicitHeight: parent.height
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Styles.margin
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
