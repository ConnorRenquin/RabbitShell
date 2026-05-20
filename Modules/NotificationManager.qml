pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Settings
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
    Themer {
        id: theme
        settingName: 'notificationManagerColor'
    }

    sourceComponent: FloatingWindow {
        id: root

        color: "transparent"
        title: 'Notification Manager'
        implicitWidth: 600
        implicitHeight: 900

        function clear() {
            Notifications.clear();
        }

        HyprlandFocusGrab {
            active: loader.active
            windows: [root]
            onCleared: loader.active = false
        }

        Rectangle {
            id: base
            anchors.fill: parent
            color: theme.foreground
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
                    color: theme.background
                    radius: Styles.radiusMd

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginMd

                        TextStyled {
                            text: "Notifications"
                            font.pointSize: 18
                            color: theme.text
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        TextStyled {
                            color: theme.text
                            text: `${Notifications.notifications.values.length} active`
                        }

                        ButtonStyled {
                            id: clearButton
                            implicitHeight: 40
                            implicitWidth: clearAllText.implicitWidth + Styles.marginLg
                            onClicked: root.clear()
                            defaultColor: theme.foreground
                            TextStyled {
                                id: clearAllText
                                color: theme.text
                                anchors.centerIn: parent
                                textFormat: Text.MarkdownText
                                text: '<u>C</u>lear All'
                            }
                        }
                    }
                }

                ClippingRectangle {
                    id: scrollContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    radius: Styles.radiusSm

                    ListView {
                        id: notificationList
                        anchors.fill: parent
                        spacing: Styles.marginSm
                        clip: true
                        model: Notifications.notifications
                        delegate: NotificationCard {
                            id: notificationItem
                            width: scrollContainer.width
                            autoExpire: false
                            showCloseButton: true
                            onDismissed: {
                                notification.dismiss();
                                notification.tracked = false;
                            }
                        }

                        Rectangle {
                            id: emptyState
                            anchors.centerIn: parent
                            visible: notificationList.count === 0
                            radius: Styles.radiusLg
                            implicitWidth: 300
                            implicitHeight: 60
                            color: theme.background
                            TextStyled {
                                anchors.centerIn: parent
                                text: "No notifications"
                                color: theme.text
                            }
                        }
                    }
                }
            }
        }
    }
}
