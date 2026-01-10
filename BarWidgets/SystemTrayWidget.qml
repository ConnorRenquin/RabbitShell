pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings

Rectangle {
    id: root

    property var currentOpenMenu: null

    radius: Styles.radiusSm
    color: Colors.background
    implicitHeight: parent.height
    implicitWidth: row.implicitWidth + Styles.marginSm * 2

    component AnimatedMenuBackground: Rectangle {
        color: Colors.background
        radius: Styles.radiusLg
        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Styles.marginSm
        Repeater {
            id: trayRow

            model: SystemTray.items
            delegate: ButtonStyled {
                id: iconButton

                required property SystemTrayItem modelData
                required property int index

                implicitWidth: icon.implicitWidth + Styles.marginSm
                implicitHeight: icon.implicitHeight + Styles.marginSm

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton && iconButton.modelData.hasMenu) {
                        systemTrayMenu.visible = !systemTrayMenu.visible;
                    } else if (mouse.button === Qt.RightButton) {
                        iconButton.modelData.activate();
                    } else if (mouse.button === Qt.MiddleButton) {
                        iconButton.modelData.secondaryActivate();
                    }
                }

                IconImage {
                    id: icon
                    anchors.centerIn: parent
                    implicitWidth: 20
                    implicitHeight: 20
                    source: iconButton.modelData.icon
                }

                PopupWindow {
                    id: systemTrayMenu

                    implicitHeight: menuContent.implicitHeight + Styles.marginSm * 2
                    implicitWidth: menuContent.implicitWidth + Styles.marginSm * 2

                    color: "transparent"

                    anchor {
                        item: iconButton
                        rect.y: iconButton.height + 10
                        rect.x: iconButton.width / 2 - implicitWidth / 2
                    }

                    onVisibleChanged: {
                        if (visible) {
                            if (root.currentOpenMenu && root.currentOpenMenu !== systemTrayMenu) {
                                root.currentOpenMenu.visible = false;
                            }
                            root.currentOpenMenu = systemTrayMenu;
                            autoCloseManager.restart();
                        } else {
                            if (root.currentOpenMenu === systemTrayMenu) {
                                root.currentOpenMenu = null;
                            }
                            autoCloseManager.stop();
                        }
                    }

                    Timer {
                        id: autoCloseManager

                        interval: initialInterval
                        repeat: false
                        onTriggered: {
                            interval = initialInterval;
                            systemTrayMenu.visible = false;
                            stop();
                        }

                        property int initialInterval: 3000
                        property int hoverInterval: 500

                        function notifyHover() {
                            interval = hoverInterval;
                            stop();
                        }
                    }

                    QsMenuOpener {
                        id: menuOpener
                        menu: iconButton.modelData?.menu
                    }

                    AnimatedMenuBackground {
                        id: menuBackground
                        anchors.fill: parent
                        visible: systemTrayMenu.visible

                        ColumnLayout {
                            id: menuContent
                            anchors.fill: parent
                            anchors.margins: Styles.marginSm
                            spacing: 4

                            Repeater {
                                model: menuOpener.children
                                delegate: Loader {
                                    id: menuLoader

                                    required property QsMenuEntry modelData

                                    Layout.fillWidth: true

                                    sourceComponent: modelData.isSeparator ? separatorComponent : menuItemComponent

                                    Component {
                                        id: separatorComponent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            implicitHeight: 1
                                            anchors.centerIn: parent
                                            width: parent.width - Styles.marginSm * 2
                                            color: Colors.backgroundHighlighted
                                        }
                                    }

                                    Component {
                                        id: menuItemComponent
                                        Item {
                                            id: menuItemWrapper
                                            implicitWidth: menuButton.implicitWidth
                                            implicitHeight: menuButton.implicitHeight

                                            property bool submenuExpanded: false

                                            ButtonStyled {
                                                id: menuButton

                                                anchors.fill: parent

                                                implicitWidth: Math.max(180, itemText.implicitWidth + Styles.marginSm * 2)
                                                implicitHeight: itemText.implicitHeight + Styles.marginSm

                                                enabled: menuLoader?.modelData?.enabled ?? false

                                                onContainsMouseChanged: {
                                                    if (containsMouse) {
                                                        autoCloseManager.notifyHover();
                                                    } else {
                                                        autoCloseManager.restart();
                                                    }
                                                }

                                                onClicked: {
                                                    if (menuLoader.modelData.enabled) {
                                                        if (menuLoader.modelData.hasChildren) {
                                                            menuItemWrapper.submenuExpanded = !menuItemWrapper.submenuExpanded;
                                                        } else {
                                                            menuLoader.modelData.triggered();
                                                            systemTrayMenu.visible = false;
                                                        }
                                                    }
                                                }

                                                RowLayout {
                                                    id: gutterIcons

                                                    spacing: Styles.marginSm

                                                    anchors.fill: parent
                                                    anchors.margins: Styles.marginSm / 2

                                                    IconImage {
                                                        visible: menuLoader?.modelData?.icon ?? false
                                                        Layout.preferredWidth: 16
                                                        Layout.preferredHeight: 16
                                                        source: menuLoader?.modelData?.icon ?? ""
                                                    }

                                                    TextStyled {
                                                        id: itemText
                                                        text: menuLoader?.modelData?.text || ""
                                                        font.pixelSize: Styles.textSm
                                                        Layout.fillWidth: true
                                                        horizontalAlignment: Text.AlignLeft
                                                        color: menuLoader?.modelData?.enabled ? Colors.foreground : Colors.gray
                                                    }

                                                    TextStyled {
                                                        id: checkBox
                                                        text: menuLoader?.modelData?.checkState === Qt.Checked ? "✓" : ""
                                                        font.pixelSize: Styles.textSm
                                                        color: Colors.green
                                                        visible: menuLoader?.modelData?.buttonType !== 0
                                                    }

                                                    TextStyled {
                                                        id: submenu
                                                        text: "›"
                                                        font.pixelSize: Styles.textSm
                                                        color: Colors.gray
                                                        visible: menuLoader?.modelData?.hasChildren ?? false
                                                    }
                                                }
                                            }

                                            Loader {
                                                id: submenuLoader
                                                active: menuItemWrapper.submenuExpanded && menuLoader.modelData.hasChildren
                                                sourceComponent: PopupWindow {
                                                    id: submenuPopup

                                                    implicitHeight: submenuContent.implicitHeight + Styles.marginSm * 2
                                                    implicitWidth: submenuContent.implicitWidth + Styles.marginSm * 2

                                                    color: "transparent"
                                                    visible: menuItemWrapper.submenuExpanded

                                                    anchor {
                                                        item: menuButton
                                                        rect.x: menuButton.width + 5
                                                        rect.y: 0
                                                    }

                                                    QsMenuOpener {
                                                        id: submenuOpener
                                                        menu: menuLoader.modelData
                                                    }

                                                    AnimatedMenuBackground {
                                                        anchors.fill: parent
                                                        visible: submenuPopup.visible

                                                        ColumnLayout {
                                                            id: submenuContent
                                                            anchors.fill: parent
                                                            anchors.margins: Styles.marginSm
                                                            spacing: 4

                                                            Repeater {
                                                                model: submenuOpener.children
                                                                delegate: ButtonStyled {
                                                                    id: submenuButton

                                                                    required property var modelData

                                                                    Layout.fillWidth: true
                                                                    visible: text
                                                                    textPixelSize: Styles.textSm
                                                                    text: submenuButton.modelData.text || null
                                                                    enabled: submenuButton.modelData.enabled

                                                                    onContainsMouseChanged: {
                                                                        if (containsMouse) {
                                                                            autoCloseManager.notifyHover();
                                                                        } else {
                                                                            autoCloseManager.restart();
                                                                        }
                                                                    }

                                                                    onClicked: {
                                                                        if (submenuButton.modelData.enabled) {
                                                                            submenuButton.modelData.triggered();
                                                                            menuItemWrapper.submenuExpanded = false;
                                                                            systemTrayMenu.visible = false;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
