pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.Components
import qs.Services
import qs.Settings

Rectangle {
    id: root

    visible: SystemTray.items.values.length != 0
    property var currentOpenMenu: null

    Themer {
        id: theme
        settingName: 'systemTrayColor'
    }

    radius: Styles.radiusSm
    color: theme.background
    implicitHeight: parent.height
    implicitWidth: widget.implicitWidth + Styles.marginSm * 2

    HoverHandler {
        id: systemTrayWidgetHover
    }

    RowLayoutPlus {
        id: widget
        anchors.centerIn: parent
        spacing: Styles.marginSm
        model: SystemTray.items
        delegate: ButtonStyled {
            id: iconButton

            required property SystemTrayItem modelData
            required property int index

            Layout.preferredWidth: icon.implicitWidth + Styles.marginSm
            Layout.preferredHeight: icon.implicitHeight + Styles.marginSm

            defaultColor: theme.foreground

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

                implicitHeight: menuContent.implicitHeight + Styles.marginXS * 2
                implicitWidth: 200 + Styles.marginSm * 2

                color: "transparent"

                property var currentMenu: null

                onVisibleChanged: {
                    if (!visible)
                        currentMenu = null;
                }

                property bool topBarSetting: Settings.get('barPosition').value
                property var yValue: topBarSetting ? Styles.marginSm * 5 : -systemTrayMenu.height - Styles.marginMd

                anchor {
                    item: iconButton
                    rect.x:  -systemTrayMenu.width / 2
                    rect.y: yValue
                }

                QsMenuOpener {
                    id: rootMenuOpener
                    menu: iconButton.modelData?.menu
                }

                QsMenuOpener {
                    id: subMenuOpener
                    menu: systemTrayMenu.currentMenu
                }

                HoverHandler {
                    id: hoverHandler
                }

                Timer {
                    id: autoHideTimer
                    interval: 500
                    running: !hoverHandler.hovered && !systemTrayWidgetHover.hovered
                    onTriggered: systemTrayMenu.visible = false
                }

                Rectangle {
                    id: menuBackground
                    anchors.fill: parent
                    visible: systemTrayMenu.visible
                    radius: Styles.radiusSm
                    color: theme.foreground

                    ColumnLayout {
                        id: menuContent
                        anchors.fill: parent
                        anchors.margins: Styles.marginXS
                        spacing: 4

                        readonly property var buttonHeight: 28

                        ButtonStyled {
                            id: backButton
                            visible: systemTrayMenu.currentMenu !== null
                            Layout.fillWidth: true
                            textAlignment: Text.AlignLeft
                            implicitHeight: menuContent.buttonHeight
                            text: Icons.back + ' Back'
                            pointSize: Styles.textSm
                            onClicked: systemTrayMenu.currentMenu = null
                            defaultColor: theme.foreground
                        }

                        Rectangle {
                            visible: systemTrayMenu.currentMenu !== null
                            Layout.fillWidth: true
                            implicitHeight: 2
                            color: theme.text
                        }

                        ColumnLayoutPlus {
                            Layout.fillWidth: true
                            spacing: 4
                            model: systemTrayMenu.currentMenu !== null ? subMenuOpener.children : rootMenuOpener.children
                            delegate: Loader {
                                id: menuLoader

                                required property QsMenuEntry modelData

                                Layout.fillWidth: true

                                sourceComponent: modelData.isSeparator ? separatorComponent : menuItemComponent

                                Component {
                                    id: separatorComponent
                                    Rectangle {
                                        implicitHeight: 2
                                        color: theme.text
                                    }
                                }

                                Component {
                                    id: menuItemComponent

                                    ButtonStyled {
                                        id: menuButton

                                        implicitHeight: menuContent.buttonHeight
                                        enabled: menuLoader?.modelData?.enabled ?? false
                                        defaultColor: theme.foreground

                                        onClicked: {
                                            if (!menuLoader.modelData.enabled)
                                                return;
                                            if (menuLoader.modelData.hasChildren) {
                                                systemTrayMenu.currentMenu = menuLoader.modelData;
                                            } else {
                                                menuLoader.modelData.triggered();
                                                systemTrayMenu.visible = false;
                                            }
                                        }

                                        RowLayout {
                                            id: gutterIcons

                                            spacing: Styles.marginSm

                                            anchors.fill: parent
                                            anchors.centerIn: parent
                                            anchors.leftMargin: Styles.marginSm
                                            anchors.rightMargin: Styles.marginSm

                                            IconImage {
                                                visible: menuLoader?.modelData?.icon ?? false
                                                Layout.preferredWidth: 16
                                                Layout.preferredHeight: 16
                                                source: menuLoader?.modelData?.icon ?? ""
                                            }

                                            TextStyled {
                                                id: itemText
                                                text: menuLoader?.modelData?.text || ""
                                                font.pointSize: Styles.textSm
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignLeft
                                                color: theme.text
                                            }

                                            TextStyled {
                                                id: checkBox
                                                text: menuLoader?.modelData?.checkState === Qt.Checked ? Icons.checkBoxChecked : Icons.checkBoxUnChecked
                                                font.pointSize: Styles.textSm
                                                color: theme.text
                                                visible: menuLoader?.modelData?.buttonType !== 0
                                            }

                                            TextStyled {
                                                id: submenuArrow
                                                text: Icons.rightChevron
                                                font.pointSize: Styles.textSm
                                                visible: menuLoader?.modelData?.hasChildren ?? false
                                                color: theme.text
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
