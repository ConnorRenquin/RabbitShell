pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings
import qs.Services

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root

        anchors.top: true
        implicitWidth: notificationList.implicitWidth
        implicitHeight: notificationList.implicitHeight + Styles.marginSm * 2
        screen: modelData

        exclusionMode: ExclusionMode.Normal
        color: "transparent"

        mask: Region {
            item: notificationList
        }

        property var modelData: null
        property bool focusGrabbed: false

        HyprlandFocusGrab {
            active: root.focusGrabbed
            windows: [root]
            onCleared: root.focusGrabbed = false
        }

        Component.onCompleted: {
            Notifications.onNotify.connect(addNotification);
        }

        property int maxPopups: 4

        function addNotification(notification) {
            if (!notification)
                return;

            if (notificationList.children.length >= maxPopups)
                notificationList.children[0].destroy();

            notificationPopupComponent.createObject(notificationList, {
                notification: notification,
                index: 0
            });
        }

       property Component notificationPopupComponent: NotificationCard {
            id: notificationPopup
            implicitWidth: parent.width
            showCloseButton: true
            onDismissed: notificationPopup.destroy()
            onReplyFocused: root.focusGrabbed = true
            Timer {
                id: expireTimer
                interval: 4000
                running: true
                onTriggered: notificationPopup.destroy()
            }

        }

        ColumnLayout {
            id: notificationList
            spacing: Styles.marginSm
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                margins: Styles.marginSm
            }
            width: 400
        }
    }
}
