pragma ComponentBehavior: Bound

import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Settings
import qs.Components

FloatingWindowPlus {
    id: root

    title: 'Notification Manager'
    shortcutName: "notification-manager"

    Component.onCompleted: PatchBay.openNotificationsManager.connect(toggle)

    function clear() {
        Notifications.clear();
    }

    Themer {
        id: theme
        settingName: 'notificationManagerColor'
    }

    delegate: Rectangle {
        id: base
        anchors.fill: parent
        color: theme.background
        radius: Styles.radiusMd
        focus: true

        Controls {
            id: controls
        }

        Keys.onPressed: event => {
            if (controls.quitPressed(event)) {
                root.exit();
            } else if (controls.cPressed(event)) {
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
