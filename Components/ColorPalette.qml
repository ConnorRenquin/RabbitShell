import QtQuick
import QtQuick.Layouts

import qs.Components.Plus
import qs.Settings

Rectangle {
    radius: Styles.radiusLg
    color: "black"
    RowLayoutPlus {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        model: [
            Colors.primary, Colors.onPrimary,
            Colors.primaryContainer, Colors.onPrimaryContainer,
            Colors.inversePrimary,
            Colors.secondary, Colors.onSecondary,
            Colors.secondaryContainer, Colors.onSecondaryContainer,
            Colors.tertiary, Colors.onTertiary,
            Colors.tertiaryContainer, Colors.onTertiaryContainer,
            Colors.error, Colors.onError,
            Colors.surface, Colors.onSurface,
            Colors.surfaceVariant, Colors.onSurfaceVariant,
            Colors.outline, Colors.outlineVariant,
            Colors.background, Colors.onBackground,
            Colors.shadow, Colors.scrim,
        ]
        delegate: Rectangle {
            required property string modelData
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Styles.radiusLg
            color: modelData
        }
    }
}
