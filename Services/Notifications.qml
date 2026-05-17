pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

import qs.Services

Singleton {
    id: root

    function init() {
        console.log('Notifications -----------------------------------------');
    }

    signal onNotify(notification: Notification)

    property alias notifications: notificationServer.trackedNotifications

    function clear() {
        const snapshot = [...notificationServer.trackedNotifications.values];
        snapshot.forEach(notification => {
            notification.dismiss();
            notification.tracked = false;
        });
    }

    function dismiss(index) {
        const values = notificationServer.trackedNotifications.values;
        if (index >= 0 && index < values.length) {
            const notification = values[index];
            notification.dismiss();
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
            if (notification.appName == '') {
                SoundEffects.playBlip();
            } else{
                SoundEffects.playNotification();
            }
            if (notification.lastGeneration)
                return;
            root.onNotify(notification);
        }
    }
}
