import Quickshell
import Quickshell.Services.Notifications
import QtQuick

NotificationServer {
    imageSupported: true
    actionsSupported: true
    actionIconsSupported: true

    onNotification: notification => {
        console.log("hello world");
        console.log(notification.summary);
    }
}
