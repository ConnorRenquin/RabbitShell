pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.Components
import qs.Components.Plus
import qs.Components.Styled
import qs.Helpers
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

    RowLayoutPlus {
        id: widget
        anchors.centerIn: parent
        spacing: Styles.marginSm
        model: SystemTray.items
        delegate: ActionMenu {
            id: iconButton

            required property SystemTrayItem modelData
            required property int index

            property var currentMenu: null

            Layout.preferredWidth: 20 + Styles.marginSm
            Layout.preferredHeight: 20 + Styles.marginSm

            defaultColor: theme.foreground
            iconSource: iconButton.modelData.icon
            iconSize: 20
            popupHeight: menuContent.implicitHeight + Styles.marginXS * 2
            popupColor: theme.background
            popupWidth: 200
            popupX: -iconButton.popupWidth / 2

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton && iconButton.modelData.hasMenu) {
                    iconButton.togglePopup();
                } else if (mouse.button === Qt.RightButton) {
                    iconButton.modelData.activate();
                } else if (mouse.button === Qt.MiddleButton) {
                    iconButton.modelData.secondaryActivate();
                }
            }

            onPopupClosed: iconButton.currentMenu = null

                QsMenuOpener {
                    id: rootMenuOpener
                    menu: iconButton.modelData?.menu
                }

                QsMenuOpener {
                    id: subMenuOpener
                    menu: iconButton.currentMenu
                }

                ColumnLayout {
                    id: menuContent
                    anchors.fill: parent
                    spacing: 4

                    readonly property int buttonHeight: 28

                    ButtonStyled {
                        id: backButton
                        visible: iconButton.currentMenu !== null
                        Layout.fillWidth: true
                        textAlignment: Text.AlignLeft
                        implicitHeight: menuContent.buttonHeight
                        text: Icons.back + ' Back'
                        textColor: theme.text
                        pointSize: Styles.textSm
                        onClicked: iconButton.currentMenu = null
                        defaultColor: theme.background
                    }

                    Rectangle {
                        visible: iconButton.currentMenu !== null
                        Layout.fillWidth: true
                        implicitHeight: 2
                        color: theme.text
                    }

                    ColumnLayoutPlus {
                        Layout.fillWidth: true
                        spacing: 4
                        model: iconButton.currentMenu !== null ? subMenuOpener.children : rootMenuOpener.children
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
                                    defaultColor: theme.background

                                    onClicked: {
                                        if (!menuLoader.modelData.enabled)
                                            return;
                                        if (menuLoader.modelData.hasChildren) {
                                            iconButton.currentMenu = menuLoader.modelData;
                                        } else {
                                            menuLoader.modelData.triggered();
                                            iconButton.closePopup();
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
