pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    function init() {
        console.log('Notifications -----------------------------------------');
    }

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
        inlineReplySupported: true
        onNotification: notification => {
            notification.tracked = true;
            notification.closed.connect(() => {
                const idx = root.notifications.indexOf(notification);
                if (idx !== -1)
                    root.notifications.splice(idx, 1);
            });
            root.notifications.unshift(notification);
            if (notification.lastGeneration)
                return;
            root.onNotify(notification);
        }
    }
}
