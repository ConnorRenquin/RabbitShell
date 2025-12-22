pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root
    signal onNotify(notification: Notification)
    readonly property NotificationServer server: notificationServer

    NotificationServer {
        id: notificationServer
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        onNotification: notification => {
            notification.tracked = true;
            root.onNotify(notification);
        }
    }
}
