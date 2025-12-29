pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Constants
import qs.Components

Loader {
    id: loader

    active: false

    function toggle() {
        loader.active = !loader.active;
    }

    Component.onCompleted: PatchBay.openNotificationsManager.connect(toggle)

    GlobalShortcut {
        name: "notification-manager"
        onPressed: loader.toggle()
    }

    sourceComponent: PanelWindow {
        id: root

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 600
        implicitHeight: 900

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        Rectangle {
            id: base
            anchors.fill: parent
            color: Colors.background
            radius: Styles.radiusMd
            focus: true

            Keys.onPressed: event => {
                if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                    loader.active = false;
                } else if ([Qt.Key_C].includes(event.key)) {
                    clearButton.clicked(null);
                }
            }

            ColumnLayout {
                id: mainContent
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                Rectangle {
                    id: controlSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: Colors.bg0
                    radius: Styles.radiusMd

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginMd

                        TextStyled {
                            text: "Notifications"
                            font.pixelSize: 18
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        TextStyled {
                            text: `${Notifications.notifications.length} active`
                        }

                        ButtonStyled {
                            id: clearButton
                            implicitHeight: 40
                            implicitWidth: clearAllText.implicitWidth + Styles.marginLg
                            radius: Styles.radiusSm
                            defaultColor: Colors.orange
                            onClicked: Notifications.clear()

                            TextStyled {
                                id: clearAllText
                                anchors.centerIn: parent
                                textFormat: Text.MarkdownText
                                text: '<u>C</u>lear All'
                                color: Colors.background
                            }
                        }
                    }
                }

                ClippingRectangle {
                    id: scrollContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    radius: Styles.radiusMd

                    ListView {
                        id: notificationList
                        anchors.fill: parent
                        spacing: Styles.marginSm
                        clip: true

                        model: Notifications.notifications
                        delegate: Rectangle {
                            id: notificationItem
                            required property Notification modelData
                            required property int index

                            implicitWidth: scrollContainer.width
                            implicitHeight: notificationContent.implicitHeight + Styles.marginMd * 2
                            color: Colors.bg0
                            radius: Styles.radiusMd

                            ColumnLayout {
                                id: notificationContent
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                    margins: Styles.marginMd
                                }
                                spacing: Styles.marginSm

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Styles.marginMd

                                    TextStyled {
                                        text: notificationItem.modelData?.appName ?? "Unknown"
                                        visible: text
                                        font.bold: true
                                        color: Colors.orange
                                        Layout.fillWidth: true
                                    }

                                    ButtonStyled {
                                        implicitHeight: 30
                                        implicitWidth: dismissText.implicitWidth + Styles.marginMd
                                        radius: Styles.radiusSm
                                        defaultColor: Colors.bg0
                                        onClicked: Notifications.dismiss(notificationItem.index)

                                        TextStyled {
                                            id: dismissText
                                            anchors.centerIn: parent
                                            text: 'Dismiss'
                                            font.pixelSize: Styles.textSm
                                        }
                                    }
                                }

                                TextStyled {
                                    text: notificationItem.modelData.summary ?? ""
                                    visible: text
                                    Layout.fillWidth: true
                                    font.pixelSize: Styles.textMd
                                }

                                TextStyled {
                                    visible: text
                                    text: notificationItem.modelData.body ?? ""
                                    Layout.fillWidth: true
                                    color: Colors.foreground
                                    font.pixelSize: Styles.textSm
                                }
                            }
                        }

                        Rectangle {
                            id: emptyState
                            anchors.centerIn: parent
                            visible: notificationList.count === 0
                            width: parent.width
                            height: 100
                            color: "transparent"

                            TextStyled {
                                anchors.centerIn: parent
                                text: "No notifications"
                                color: Colors.foreground
                                opacity: 0.5
                                font.pixelSize: 16
                            }
                        }
                    }
                }
            }
        }
    }
}
