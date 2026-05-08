pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
import qs.Services

import qs.Modules.ClipboardViews

FloatingWindow {
    id: root

    visible: false
    title: 'Clipboard'

    implicitWidth: 700
    implicitHeight: 900
    color: "transparent"

    property int currentTab: 0
    readonly property var tabNames: [
        Icons.copy + " Text",
        Icons.image + " Images",
        Icons.emoji + " Emojis"
    ]

    function exit() {
        root.visible = false;
        grab.active = false;
    }

    function show(tabIndex: int) {
        root.currentTab = tabIndex;
        root.visible = true;
        grab.active = true;
        base.forceActiveFocus();
    }

    function cycleTab(forward: bool) {
        if (forward) {
            root.currentTab = (root.currentTab + 1) % 3;
        } else {
            root.currentTab = (root.currentTab + 2) % 3;
        }
    }

    onCurrentTabChanged: {
        if (currentTab !== 0) {
            base.forceActiveFocus();
        }
    }

    function toggle(tabIndex: int) {
        if (root.visible && root.currentTab === tabIndex) {
            root.exit();
        } else {
            root.show(tabIndex);
        }
    }

    GlobalShortcut {
        name: 'clipboard'
        onPressed: root.toggle(0)
    }

    GlobalShortcut {
        name: 'image-clipboard'
        onPressed: root.toggle(1)
    }

    GlobalShortcut {
        name: 'asciimojis'
        onPressed: root.toggle(2)
    }

    Connections {
        target: PatchBay
        function onOpenImageClipboard() { root.toggle(1); }
        function onOpenAsciiEmojis() { root.toggle(2); }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        onCleared: root.exit()
    }

    Rectangle {
        id: base
        anchors.fill: parent
        color: Colors.secondaryContainer
        radius: Styles.radiusSm
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
                root.cycleTab(true);
                event.accepted = true;
                return;
            }
            if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                root.cycleTab(false);
                event.accepted = true;
                return;
            }
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.exit();
                event.accepted = true;
                return;
            }
        }

        ColumnLayout {
            anchors.fill: parent

            Rectangle {
                id: tabBar
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: Colors.secondary
                radius: Styles.radiusSm

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginXS
                    spacing: Styles.marginSm

                    Repeater {
                        model: root.tabNames
                        delegate: ButtonStyled {
                            id: tabButton

                            required property string modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: tabButton.modelData
                            isFocused: root.currentTab === tabButton.index
                            defaultColor: Colors.onSecondary
                            onClicked: {
                                root.currentTab = tabButton.index;
                                base.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            Item {
                id: viewContainer
                Layout.fillHeight: true
                Layout.fillWidth: true

                TextClipboardView {
                    id: textView
                    anchors.fill: parent
                    visible: root.currentTab === 0
                    isActive: root.currentTab === 0
                    onRequestExit: root.exit()
                    onRequestTabCycle: forward => root.cycleTab(forward)
                }

                ImageClipboardView {
                    id: imageView
                    anchors.fill: parent
                    visible: root.currentTab === 1
                    isActive: root.currentTab === 1
                }

                AsciiEmojisView {
                    id: emojiView
                    anchors.fill: parent
                    visible: root.currentTab === 2
                    isActive: root.currentTab === 2
                    onRequestExit: root.exit()
                }
            }
        }
    }
}
