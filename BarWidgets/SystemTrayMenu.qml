pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

import qs.Components
import qs.Constants

PopupWindowAnimated {
    id: root

    required property SystemTrayItem item

    implicitHeight: menuContent.implicitHeight + Styles.marginSm * 2
    implicitWidth: menuContent.implicitWidth + Styles.marginSm * 2

    anchor {
        item: parent
        rect.y: parent.height + 10
        rect.x: parent.width / 2 - implicitWidth / 2
    }

    QsMenuOpener {
        id: menuOpener
        menu: root.item.menu
    }

    // Auto-close timer
    Timer {
        id: autoCloseTimer
        interval: 500
        repeat: false
        onTriggered: {
            root.hide();
        }
    }

    // Track when menu opens/closes to manage timer
    onIsOpenChanged: {
        if (isOpen) {
            autoCloseTimer.restart();
        } else {
            autoCloseTimer.stop();
        }
    }

    Rectangle {
        id: menuBackground
        anchors.fill: parent
        color: Colors.bgDim
        radius: Styles.radiusLg

        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.95

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

        ColumnLayout {
            id: menuContent
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            spacing: 4

            Repeater {
                model: menuOpener.children

                Loader {
                    id: menuLoader
                    required property QsMenuEntry modelData

                    Layout.fillWidth: true

                    sourceComponent: modelData.isSeparator ? separatorComponent : menuItemComponent

                    Component {
                        id: separatorComponent

                        Item {
                            implicitHeight: 5
                            implicitWidth: 180

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - Styles.marginSm * 2
                                height: 1
                                color: Colors.bg3
                            }
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

                                defaultColor: Colors.transparent
                                hoverColor: Colors.bg2
                                radius: Styles.radiusSm

                                enabled: menuLoader.modelData.enabled
                                opacity: menuLoader.modelData.enabled ? 1.0 : 0.5

                                // Control auto-close timer based on hover
                                onContainsMouseChanged: {
                                    if (containsMouse) {
                                        autoCloseTimer.stop();
                                    } else {
                                        autoCloseTimer.restart();
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Styles.marginSm / 2
                                    spacing: Styles.marginSm

                                    // Optional icon space
                                    Item {
                                        Layout.preferredWidth: 16
                                        Layout.preferredHeight: 16
                                        visible: menuLoader.modelData.icon !== undefined && menuLoader.modelData.icon !== null

                                        IconImage {
                                            anchors.centerIn: parent
                                            width: parent.width
                                            height: parent.height
                                            source: menuLoader.modelData.icon || ""
                                        }
                                    }

                                    TextStyled {
                                        id: itemText
                                        text: menuLoader.modelData.text || ""
                                        font.pixelSize: 14
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignLeft
                                        color: menuLoader.modelData.enabled ? Colors.fg : Colors.grey0
                                    }

                                    // Checkbox/Radio indicator
                                    TextStyled {
                                        text: menuLoader.modelData.checkState === Qt.Checked ? "✓" : ""
                                        font.pixelSize: 14
                                        color: Colors.green
                                        visible: menuLoader.modelData.buttonType !== 0
                                    }

                                    // Submenu arrow
                                    TextStyled {
                                        text: "›"
                                        font.pixelSize: 14
                                        color: Colors.grey1
                                        visible: menuLoader.modelData.hasChildren
                                    }
                                }

                                onClicked: {
                                    if (menuLoader.modelData.enabled) {
                                        if (menuLoader.modelData.hasChildren) {
                                            // Toggle submenu
                                            menuItemWrapper.submenuExpanded = !menuItemWrapper.submenuExpanded;
                                        } else {
                                            // Regular item - trigger and close
                                            menuLoader.modelData.triggered();
                                            root.hide();
                                        }
                                    }
                                }

                                // Animation on hover
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }
                            }

                            // Submenu popup
                            Loader {
                                id: submenuLoader
                                active: menuItemWrapper.submenuExpanded && menuLoader.modelData.hasChildren

                                sourceComponent: PopupWindowAnimated {
                                    id: submenuPopup

                                    implicitHeight: submenuContent.implicitHeight + Styles.marginSm * 2
                                    implicitWidth: submenuContent.implicitWidth + Styles.marginSm * 2

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

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Colors.bgDim
                                        radius: Styles.radiusLg
                                        opacity: submenuPopup.isOpen ? 1 : 0
                                        scale: submenuPopup.isOpen ? 1 : 0.95

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

                                        ColumnLayout {
                                            id: submenuContent
                                            anchors.fill: parent
                                            anchors.margins: Styles.marginSm
                                            spacing: 4

                                            Repeater {
                                                model: submenuOpener.children

                                                ButtonStyled {
                                                    id: submenuButton
                                                    required property var modelData

                                                    Layout.fillWidth: true

                                                    implicitWidth: Math.max(180, submenuText.implicitWidth + Styles.marginSm * 2)
                                                    implicitHeight: submenuText.implicitHeight + Styles.marginSm

                                                    defaultColor: Colors.transparent
                                                    hoverColor: Colors.bg2
                                                    radius: Styles.radiusSm

                                                    enabled: submenuButton.modelData.enabled
                                                    opacity: submenuButton.modelData.enabled ? 1.0 : 0.5

                                                    // Control auto-close timer based on hover
                                                    onContainsMouseChanged: {
                                                        if (containsMouse) {
                                                            autoCloseTimer.stop();
                                                        } else {
                                                            autoCloseTimer.restart();
                                                        }
                                                    }

                                                    TextStyled {
                                                        id: submenuText
                                                        text: submenuButton.modelData.text || ""
                                                        font.pixelSize: 14
                                                        anchors.centerIn: parent
                                                        color: submenuButton.modelData.enabled ? Colors.fg : Colors.grey0
                                                    }

                                                    onClicked: {
                                                        if (submenuButton.modelData.enabled) {
                                                            submenuButton.modelData.triggered();
                                                            menuItemWrapper.submenuExpanded = false;
                                                            root.hide();
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Component.onCompleted: {
                                        submenuPopup.show();
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
