import Quickshell
import Quickshell.Widgets
import QtQuick
import Quickshell.Services.SystemTray

import qs.Components
import qs.Constants

PopupWindow {
    id: root

    property QsMenuHandle trayMenu

    anchor {
        item: parent
        rect.y: parent.height + 15
        rect.x: parent.implicitWidth / 2 - implicitWidth / 2
    }

    color: "transparent"
    implicitHeight: menuBackground.implicitHeight + Styles.marginSm
    implicitWidth: menuBackground.implicitWidth + Styles.marginSm

    QsMenuOpener {
        id: menuOpener
        menu: root.trayMenu
    }

    Rectangle {
        id: menuBackground
        color: Colors.bg0
        radius: Styles.radiusSm
        anchors.fill: parent
        implicitHeight: contentColumn.implicitHeight
        implicitWidth: contentColumn.implicitWidth

        Column {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                centerIn: parent
            }
            spacing: 10
            Repeater {
                model: menuOpener.children.values
                delegate: ButtonStyled {
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: Styles.radiusSm
                    implicitWidth: 200

                    implicitHeight: modelData.isSeperator || modelData.text == "" ? 2 : (textContent.implicitHeight + 10)

                    TextStyled {
                        id: textContent
                        anchors.centerIn: parent
                        text: modelData.text
                        width: parent.width - Styles.marginSm
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
