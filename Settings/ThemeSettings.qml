import QtQuick
import QtQuick.Layouts

import qs.Constants
import qs.Components
import qs.Services

Rectangle {
    id: base

    color: Colors.backgroundLifted
    radius: 8

    anchors.fill: parent

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        anchors.fill: parent
        spacing: 12

        TextStyled {
            Layout.alignment: Qt.AlignCenter
            text: "Choose Theme"
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 2
            color: Colors.backgroundHighlighted
        }

        GridLayout {
            columns: 2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: ThemeManager.availableThemes

                ButtonStyled {
                    id: themeButton
                    required property string modelData
                    required property int index

                    Layout.margins: Styles.marginSm
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Layout.preferredHeight: 40
                    Layout.maximumHeight: 91

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
    }
}
