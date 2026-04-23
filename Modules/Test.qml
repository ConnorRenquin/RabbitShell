import Quickshell
import Quickshell.Hyprland

import QtQuick

import qs.Services
import qs.Components

FloatingWindow {
    color: "transparent"
    QtObject {
        id: testAction1
        property string text: "Accept"
        property string identifier: "accept"
        function invoke() { console.log("Accept clicked"); }
    }

    QtObject {
        id: testAction2
        property string text: "Decline"
        property string identifier: "decline"
        function invoke() { console.log("Decline clicked"); }
    }

    QtObject {
        id: testNotification

        property string appName: "Spotify"
        property string appIcon: "spotify"
        property string summary: "This is the summary..."
        property string body: "This is a test notification body with some longer text to see how it displays.\n\nIt even has multiple paragraphs!"
        property string image: "/home/connor/Pictures/Wallpapers/ivy.jpeg"
        property int urgency: 1
        property bool tracked: true
        property bool resident: false
        property bool hasInlineReply: true
        property string inlineReplyPlaceholder: "Type your reply..."
        property bool hasActionIcons: false
        property bool isTransient: false
        property real expireTimeout: 5
        property int id: 1
        property bool lastGeneration: false
        property string desktopEntry: ""
        property var hints
        property var actions: [testAction1, testAction2]

        function sendInlineReply(replyText) {
            console.log("Inline reply sent:", replyText);
        }

        function dismiss() {
            console.log("Notification dismissed");
        }

        function expire() {
            console.log("Notification expired");
        }

        Component.onCompleted: {
            hints = {}
        }
    }

    NotificationCard {
        notification: testNotification
        anchors.fill: parent
        showCloseButton: true
    }
}
