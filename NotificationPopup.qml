import Quickshell
import Quickshell.Services.Notifications

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants

PanelWindow {
    id: root

    anchors.top: true
    implicitWidth: notificationList.implicitWidth
    implicitHeight: notificationList.implicitHeight + Styles.marginSm * 2

    exclusionMode: ExclusionMode.Normal
    color: Colors.transparent
    mask: Region {
        item: notificationList
    }

    Component.onCompleted: {
        NotificationService.newNotification.connect(addNotification);
    }

    function addNotification(notification: Notification) {
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

            TextStyled {
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.pixelSize: 25
                color: Colors.orange
                text: notification.appName
            }

            TextStyled {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colors.yellow
                text: notification.summary
                wrapMode: Text.WordWrap
            }

            TextStyled {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: notification.body !== ''
                text: {
                    // TODO Extract at somepoint.
                    // Ai code to move text over for indented blocks of copied text.
                    let lines = notification.body.split('\n');
                    let minIndent = Math.min(...lines.filter(line => line.trim().length > 0).map(line => line.match(/^\s*/)[0].length));
                    return lines.map(line => line.slice(minIndent)).join('\n');
                }
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }

    ColumnLayout {
        id: notificationList
        spacing: 20
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: 10
        }
        width: 400
    }
}
