import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import qs.base

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Normal
    color: Colors.transparent
    mask: Region {
        item: notificationList
    }

    Component.onCompleted: {
        NotificationService.newNotification.connect(addNotification);
    }

    function addNotification(notification: Notification) {
        console.log("hello add");
        console.log(notification.summary);
        const notificationItem = notificationPopupComponent.createObject(notificationList, {
            notification: notification
        });
    }

    property Component notificationPopupComponent: Rectangle {
        id: notificationBase
        required property Notification notification
        width: parent.width
        height: notificationContent.height + notificationContent.anchors.margins * 2

        radius: 5
        color: Colors.bgDim

        Timer {
            interval: 2000
            running: true
            onTriggered: {
                notificationBase.destroy();
            }
        }

        Column {
            id: notificationContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 10
            }
            spacing: 5

            TextStyled {
                id: title
                width: parent.width
                font.pixelSize: 25
                text: notification.appName
            }

            TextStyled {
                id: summary
                width: parent.width
                text: notification.summary
                wrapMode: Text.WordWrap
            }
        }
    }

    Column {
        id: notificationList
        spacing: 20
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: 400
    }
}
