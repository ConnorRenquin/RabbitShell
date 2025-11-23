import Quickshell
import Quickshell.Widgets
import QtQuick
import Quickshell.Services.SystemTray

import qs.Components
import qs.Constants

PopupWindowAnimated {
    id: root

    implicitHeight: menuBackground.implicitHeight + Styles.marginSm
    implicitWidth: menuBackground.implicitWidth + Styles.marginSm

    anchor {
        item: parent
        rect.y: parent.height + 15
        rect.x: parent.implicitWidth / 2 - implicitWidth / 2
    }

    property QsMenuHandle trayMenu

    QsMenuOpener {
        id: menuOpener
        menu: root.trayMenu
    }

    Rectangle {
        id: menuBackground

        implicitHeight: contentColumn.implicitHeight
        implicitWidth: contentColumn.implicitWidth

        color: Colors.bg0
        opacity: root.visible ? 1 : 0
        radius: Styles.radiusLg

        anchors.fill: parent

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }

        Column {
            id: contentColumn

            spacing: 5

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                centerIn: parent
            }

            Repeater {
                model: menuOpener.children.values.filter(modelData => !modelData.text == "")
                delegate: ButtonStyled {
                    implicitWidth: 200
                    implicitHeight: textContent.implicitHeight + Styles.marginSm * 2
                    isFocused: modelData.isSeperator

                    radius: Styles.radiusMd

                    anchors.horizontalCenter: parent.horizontalCenter

                    TextStyled {
                        id: textContent
                        text: modelData.text
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Styles.marginSm
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                    }

                    onClicked: event => {
                        modelData.triggered();
                        root.visible = !root.visible;
                    }
                }
            }
        }
    }
}
