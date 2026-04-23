pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

import QtQuick
import QtQuick.Layouts

import qs.Settings

Rectangle {
    id: root

    required property var modelData
    required property int index

    property var notification: modelData

    property bool autoExpire: true
    property bool showCloseButton: true
    property int maxHeight: 500

    signal dismissed()
    signal replyFocused()

    visible: root.notification !== null && root.notification.tracked
    implicitHeight: visible ? Math.min(notificationContent.implicitHeight + notificationContent.anchors.margins * 2, root.maxHeight) : 0
    clip: true
    color: Colors.background
    radius: Styles.radiusMd


    function removeIndentation(text) {
        if (!text) return "";
        let lines = text.split('\n');
        let minIndent = Math.min(...lines.filter(line => line.trim().length > 0).map(line => line.match(/^\s*/)[0].length));
        return lines.map(line => line.slice(minIndent)).join('\n');
    }

    ColumnLayout {
        id: notificationContent

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            spacing: Styles.marginSm
            visible: root.notification

            IconImage {
                id: appIconImage
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                source: Quickshell.iconPath(root.notification.appIcon, "bell")
                visible: root.notification?.appIcon ?? false
            }

            TextStyled {
                id: appNameText
                font.pixelSize: Styles.textLg
                visible: text
                text: root.notification?.appName ?? "Notification"
            }

            Item {
                Layout.fillWidth: true
            }

            ButtonStyled {
                id: closeButton
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                visible: root.showCloseButton
                text: Icons.close
                onClicked: root.dismissed();
            }
        }


        RowLayout {
            id: notificationInfo
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true

                TextStyled {
                    id: summaryText
                    Layout.fillWidth: true
                    visible: text
                    text: root.notification?.summary ?? ""
                    wrapMode: Text.WordWrap
                }

                TextStyled {
                    id: bodyText
                    Layout.fillWidth: true
                    font.pixelSize: Styles.textSm
                    visible: text
                    text: root.removeIndentation(root.notification?.body) ?? ""
                    wrapMode: Text.WordWrap
                }
            }
            Image {
                id: notificationImage
                Layout.preferredHeight: notificationInfo.implicitHeight
                Layout.preferredWidth: implicitHeight > 0 ? (height * implicitWidth / implicitHeight) : 0
                Layout.maximumWidth: 100
                source: root.notification?.image ?? ""
                visible: root.notification?.image ?? false
                horizontalAlignment: Image.AlignRight
                verticalAlignment: Image.AlignTop
                fillMode: Image.PreserveAspectFit
            }
        }

        RowLayout {
            id: inlineReplyRow
            Layout.fillWidth: true
            visible: root.notification?.hasInlineReply ?? false
            spacing: Styles.marginSm
            TextFieldStyled {
                id: inlineReplyInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: root.notification?.inlineReplyPlaceholder || "Reply..."
                onActiveFocusChanged: if (activeFocus) root.replyFocused()
                backgroundColor: Colors.backgroundLighter
                background: Rectangle {
                    color: inlineReplyInput.backgroundColor
                    radius: Styles.radiusSm
                }
                Keys.onReturnPressed: {
                    if (text.length <= 0) return
                    root.notification.sendInlineReply(text);
                    text = "";
                    if (!root.notification.resident) {
                        root.notification.dismiss();
                    }
                }
            }

            ButtonStyled {
                id: sendButton
                text: Icons.send
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
            spacing: Styles.marginSm
            visible: root.notification?.actions?.length > 0
            model: root.notification?.actions
            delegate: ButtonStyled {
                required property var modelData
                Layout.fillWidth: true
                text: modelData.text || modelData.identifier
                Layout.maximumHeight: 32
                pixelSize: Styles.textSm
                onClicked: {
                    modelData.invoke();
                    if (!root.notification.resident) {
                        root.notification.dismiss();
                    }
                }
            }
        }
    }
}
