pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root
    signal newNotification(notification: Notification)

    NotificationServer {
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        onNotification: notification => root.newNotification(notification)
    }
}
