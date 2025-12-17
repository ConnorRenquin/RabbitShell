import Quickshell
import Quickshell.Services.Notifications

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants

Variants {
    component NotificationText: TextStyled {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: inputText !== ''
        property string inputText: ''
        text: inputText
    }

    model: Quickshell.screens
    delegate: PanelWindow {
        id: root

        property var modelData: null
        anchors.top: true
        implicitWidth: notificationList.implicitWidth
        implicitHeight: notificationList.implicitHeight + Styles.marginSm * 2
        screen: modelData

        exclusionMode: ExclusionMode.Normal
        color: Colors.transparent
        mask: Region {
            item: notificationList
        }

        Component.onCompleted: {
            NotificationService.newNotification.connect(addNotification);
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

            implicitHeight: Math.min(notificationContent.implicitHeight + notificationContent.anchors.margins * 2, 300)
            implicitWidth: parent.width

            radius: 5

            clip: true
            onClicked: notificationBase.destroy()

            required property Notification notification

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
                    inputText: notification.appName
                }

                NotificationText {
                    color: Colors.yellow
                    inputText: notification.summary
                    wrapMode: Text.WordWrap
                }

                NotificationText {
                    font.pixelSize: Styles.textSm
                    inputText: Utils.removeIndentation(notification.body)
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
