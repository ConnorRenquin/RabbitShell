pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
import qs.Components.Styled

ColumnLayout {
    id: sectionHeader

    required property string title
    property string subtitle: ""

    Layout.fillWidth: true
    spacing: 2

    TextStyled {
        Layout.fillWidth: true
        text: sectionHeader.title
        font.pointSize: Styles.textMd
    }

    TextStyled {
        Layout.fillWidth: true
        visible: sectionHeader.subtitle.length > 0
        text: sectionHeader.subtitle
        color: Colors.onSurfaceVariant
        font.pointSize: Styles.textSm
    }
}
