import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components

Rectangle {
    id: base

    color: Colors.backgroundLifted
    anchors.fill: parent

    ListView {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        model: Colors.availableThemes
        spacing: Styles.marginSm
        delegate: ButtonStyled {
            id: themeButton

            required property string modelData
            required property int index

            Layout.margins: Styles.marginSm
            Layout.fillWidth: true

            implicitWidth: parent.width

            defaultColor: isActive ? Colors.primary : Colors.backgroundHighlighted
            hoverColor: isActive ? Colors.primary : Colors.backgroundLifted

            onClicked: Colors.currentTheme = modelData

            readonly property bool isActive: Colors.currentTheme === modelData

            TextStyled {
                anchors.centerIn: parent
                text: themeButton.modelData.split('.')[0]
                color: themeButton.isActive ? Colors.background : Colors.foreground
                font.pixelSize: Styles.textSm
            }
        }
    }
}
