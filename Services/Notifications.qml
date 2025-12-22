pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root
    signal onNotify(notification: Notification)

    property list<Notification> notifications: []

    function clear() {
        notifications = [];
        notificationServer.trackedNotifications.values.forEach(notification => notification.tracked = false);
    }

    function dismiss(index) {
        if (index >= 0 && index < notifications.length) {
            const notification = notifications[index];
            notifications.splice(index, 1);
            notification.tracked = false;
        }
    }

    NotificationServer {
        id: notificationServer
        imageSupported: true
        actionsSupported: true
        keepOnReload: true
        actionIconsSupported: true
        persistenceSupported: true
        onNotification: notification => {
            notification.tracked = true;
            root.notifications.unshift(notification); // Add new notifications at the beginning
            if (notification.lastGeneration)
                return;
            root.onNotify(notification);
        }
    }
}
