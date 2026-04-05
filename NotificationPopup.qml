pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import Quickshell.Wayland

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
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        screen: modelData
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.namespace: "notifications"
        WlrLayershell.layer: WlrLayer.Overlay

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
                modelData: notification,
                index: 0
            });
        }

        property Component notificationPopupComponent: NotificationCard {
            id: notificationPopup
            Layout.fillWidth: true
            showCloseButton: true
            onDismissed: notificationPopup.destroy()
            onReplyFocused: root.focusGrabbed = true

            transformOrigin: Item.Top
            scale: scaleTarget
            property real scaleTarget: 0
            Component.onCompleted: scaleTarget = 1

            NumberAnimation on scale {
                duration: 150
                easing.type: Easing.OutCubic
            }
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
            width: 400
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                margins: Styles.marginLg * 2
            }
        }
    }
}
