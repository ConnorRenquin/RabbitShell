
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components

Rectangle {
    id: root

    required property string title
    property string subTitle

    Layout.fillWidth: true
    Layout.preferredHeight: titlebar.implicitHeight + Styles.marginSm * 2
    color: Colors.surface
    radius: Styles.radiusLg

    RowLayout {
        id: titlebar
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            TextStyled {
                Layout.fillWidth: true
                text: root.title
                font.pointSize: Styles.textLg
            }
            TextStyled {
                Layout.fillWidth: true
                text: root.subTitle
                color: Colors.onSurfaceVariant
                font.pointSize: Styles.textSm
            }
        }
    }
}
