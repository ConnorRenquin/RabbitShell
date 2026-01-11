pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Settings
import qs.Components

Rectangle {
    id: base

    color: Colors.backgroundLifted

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        GridLayoutPlus {
            id: grid
            columns: 2
            layoutDirection: GridLayout.TopToBottom
            anchors.left: parent.left
            anchors.right: parent.right
            model: Colors.availableThemes
            delegate: ButtonStyled {
                id: themeButton

                required property string modelData
                required property int index

                Layout.preferredWidth: 200
                Layout.margins: Styles.marginSm
                Layout.fillWidth: true

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
}
