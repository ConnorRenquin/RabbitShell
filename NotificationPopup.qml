pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants
import qs.Services

Variants {
    component NotificationText: TextStyled {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    model: Quickshell.screens
    delegate: PanelWindow {
        id: root

        Utils {
            id: utils
        }

        property var modelData: null
        anchors.top: true
        implicitWidth: notificationList.implicitWidth
        implicitHeight: notificationList.implicitHeight + Styles.marginSm * 2
        screen: modelData

        exclusionMode: ExclusionMode.Normal
        color: "transparent"
        mask: Region {
            item: notificationList
        }

        Component.onCompleted: {
            Notifications.onNotify.connect(addNotification);
        }

        function addNotification(notification) {
            if (!notification)
                return;
            notificationPopupComponent.createObject(notificationList, {
                notification: notification
            });
        }

        property Component notificationPopupComponent: ButtonStyled {
            id: notificationBase

            required property Notification notification

            implicitHeight: Math.min(notificationContent.implicitHeight + notificationContent.anchors.margins * 2, 300)
            implicitWidth: parent.width

            radius: 5

            clip: true
            onClicked: notificationBase.destroy()

            Timer {
                interval: 4000
                running: true
                onTriggered: notificationBase.destroy()
            }

            ColumnLayout {
                id: notificationContent

                height: parent.height
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                NotificationText {
                    font.pixelSize: Styles.textLg
                    color: Colors.orange
                    visible: text
                    text: notificationBase.notification?.appName ?? text
                }

                NotificationText {
                    color: Colors.yellow
                    visible: text
                    text: notificationBase.notification?.summary ?? text
                    wrapMode: Text.WordWrap
                }

                NotificationText {
                    font.pixelSize: Styles.textSm
                    visible: text
                    text: utils.removeIndentation(notificationBase.notification?.body) ?? text
                    wrapMode: Text.NoWrap
                }
            }
        }

        ColumnLayout {
            id: notificationList
            spacing: 20
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                margins: Styles.marginSm
            }
            width: 400
        }
    }
}
