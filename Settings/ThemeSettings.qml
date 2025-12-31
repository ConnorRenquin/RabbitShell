import QtQuick
import QtQuick.Layouts

import qs.Constants
import qs.Components
import qs.Services

Rectangle {
    id: base

    color: Colors.backgroundLifted
    anchors.fill: parent

    ListView {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        model: ThemeManager.availableThemes
        spacing: Styles.marginSm
        delegate: ButtonStyled {
            id: themeButton

            required property string modelData
            required property int index

            Layout.margins: Styles.marginSm
            Layout.fillWidth: true

            implicitWidth: parent.width
            // Layout.preferredHeight: 40
            // Layout.maximumHeight: 90

            readonly property bool isActive: ThemeManager.currentTheme === modelData

            defaultColor: isActive ? Colors.primary : Colors.backgroundHighlighted
            hoverColor: isActive ? Colors.primary : Colors.backgroundLifted

            onClicked: ThemeManager.setTheme(modelData)

            TextStyled {
                anchors.centerIn: parent
                text: themeButton.modelData.split("-").map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(" ")
                color: themeButton.isActive ? Colors.background : Colors.foreground
                font.pixelSize: Styles.textSm
            }
        }
    }
}
