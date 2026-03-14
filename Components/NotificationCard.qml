pragma ComponentBehavior: Bound

import Quickshell.Services.Notifications

import QtQuick
import QtQuick.Layouts

import qs.Settings

Rectangle {
    id: root

    property Notification notification: null

    property bool autoExpire: true
    property bool showCloseButton: true
    property int maxHeight: 500

    signal dismissed()
    signal replyFocused()

    visible: root.notification !== null && root.notification.tracked
    implicitHeight: visible ? Math.min(notificationContent.implicitHeight + notificationContent.anchors.margins * 2, root.maxHeight) : 0
    clip: true
    color: Colors.backgroundLifted
    radius: Styles.radiusMd

    property color urgencyColor: {
        if (!root.notification) return Colors.orange;
        switch (root.notification.urgency) {
            case NotificationUrgency.Critical:
                return Colors.error;
            case NotificationUrgency.Normal:
                return Colors.orange;
            case NotificationUrgency.Low:
                return Colors.foreground;
            default:
                return Colors.orange;
        }
    }

    function removeIndentation(text) {
        if (!text) return "";
        let lines = text.split('\n');
        let minIndent = Math.min(...lines.filter(line => line.trim().length > 0).map(line => line.match(/^\s*/)[0].length));
        return lines.map(line => line.slice(minIndent)).join('\n');
    }

    Connections {
        id: closedConnection
        target: root.notification
        enabled: root.notification !== null
        function onClosed(reason) {
            root.dismissed();
        }
    }

    Timer {
        id: expireTimer
        interval: {
            if (!root.notification) return 5000;
            if (root.notification.expireTimeout > 0) {
                return root.notification.expireTimeout * 1000;
            } else if (root.notification.urgency === NotificationUrgency.Critical) {
                return 10000;
            } else {
                return 5000;
            }
        }
        running: root.autoExpire
            && root.notification !== null
            && root.notification.tracked
            && !root.notification.resident
        onTriggered: root.dismissed()
    }

    ColumnLayout {
        id: notificationContent

        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            spacing: Styles.marginSm
            visible: root.notification && (root.notification.appIcon || root.notification.appName)

            Image {
                id: appIconImage
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                source: root.notification?.appIcon ?? ""
                visible: root.notification?.appIcon ?? false
                fillMode: Image.PreserveAspectFit
            }

            TextStyled {
                id: appNameText
                Layout.fillWidth: true
                font.pixelSize: Styles.textLg
                font.bold: true
                color: root.urgencyColor
                visible: text
                text: root.notification?.appName ?? ""
            }

            TextStyled {
                id: restoredBadgeText
                font.pixelSize: Styles.textSm
                color: Colors.foreground
                opacity: 0.5
                visible: root.notification?.lastGeneration ?? false
                text: "[restored]"
            }

            Item {
                id: headerSpacer
                Layout.fillWidth: true
            }

            ButtonStyled {
                id: closeButton
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                visible: root.showCloseButton
                text: "×"
                onClicked: {
                    if (root.notification && root.notification.tracked) {
                        root.notification.dismiss();
                    }
                }
            }
        }

        TextStyled {
            id: summaryText
            Layout.fillWidth: true
            color: Colors.yellow
            font.bold: true
            visible: text
            text: root.notification?.summary ?? ""
            wrapMode: Text.WordWrap
        }

        Image {
            id: notificationImage
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            Layout.maximumHeight: 200
            source: root.notification?.image ?? ""
            visible: root.notification?.image ?? false
            fillMode: Image.PreserveAspectFit
        }

        TextStyled {
            id: bodyText
            Layout.fillWidth: true
            font.pixelSize: Styles.textSm
            visible: text
            text: root.removeIndentation(root.notification?.body) ?? ""
            wrapMode: Text.Wrap
        }

        RowLayout {
            id: inlineReplyRow
            Layout.fillWidth: true
            visible: root.notification?.hasInlineReply ?? false
            spacing: Styles.marginSm
            TextFieldStyled {
                id: inlineReplyInput
                Layout.fillWidth: true
                placeholderText: root.notification?.inlineReplyPlaceholder || "Type a reply..."
                onActiveFocusChanged: if (activeFocus) root.replyFocused()
                backgroundColor: Colors.background
                background: Rectangle {
                    color: inlineReplyInput.backgroundColor
                    radius: Styles.radiusSm
                }
                Keys.onReturnPressed: {
                    if (text.length > 0 && root.notification) {
                        root.notification.sendInlineReply(text);
                        text = "";
                        if (!root.notification.resident) {
                            root.notification.dismiss();
                        }
                    }
                }
            }

            ButtonStyled {
                id: sendButton
                text: "Send"
                enabled: inlineReplyInput.text.length > 0
                onClicked: {
                    if (inlineReplyInput.text.length > 0 && root.notification) {
                        root.notification.sendInlineReply(inlineReplyInput.text);
                        inlineReplyInput.text = "";
                        if (!root.notification.resident) {
                            root.notification.dismiss();
                        }
                    }
                }
            }
        }

        RowLayoutPlus {
            id: actionsRow
            Layout.fillWidth: true
            spacing: Styles.marginSm
            visible: root.notification?.actions?.length > 0

            model: root.notification?.actions ?? []
            delegate: ButtonStyled {
                required property var modelData

                text: modelData.text || modelData.identifier

                Image {
                    id: actionIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 4
                    width: 16
                    height: 16
                    source: (root.notification?.hasActionIcons && modelData.identifier)
                        ? "image://icon/" + modelData.identifier
                        : ""
                    visible: root.notification?.hasActionIcons && source
                    fillMode: Image.PreserveAspectFit
                }

                onClicked: {
                    modelData.invoke();
                    if (root.notification && !root.notification.resident) {
                        root.notification.dismiss();
                    }
                }
            }
        }
    }
}
