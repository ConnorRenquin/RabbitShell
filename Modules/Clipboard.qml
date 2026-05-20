pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Components
import qs.Services

import qs.Modules.ClipboardViews

FloatingWindowPlus {
    id: root

    title: 'Clipboard'

    property int currentTab: 0

    function show(tabIndex: int) {
        open()
        root.currentTab = tabIndex;
    }

    function cycleTab(forward: bool) {
        if (forward) {
            root.currentTab = (root.currentTab + 1) % 3;
        } else {
            root.currentTab = (root.currentTab + 2) % 3;
        }
    }

    Themer {
        id: theme
        settingName: 'clipboardColor'
    }

    GlobalShortcut {
        name: 'clipboard'
        onPressed: root.show(0)
    }

    GlobalShortcut {
        name: 'image-clipboard'
        onPressed: root.show(1)
    }

    GlobalShortcut {
        name: 'asciimojis'
        onPressed: root.show(2)
    }

    Connections {
        target: PatchBay
        function onOpenImageClipboard() {
            root.show(1);
        }
        function onOpenAsciiEmojis() {
            root.show(2);
        }
    }

    delegate: Rectangle {
        id: base
        anchors.fill: parent
        color: theme.background
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
                color: theme.foreground
                radius: Styles.radiusSm

                RowLayoutPlus {
                    anchors.fill: parent
                    anchors.margins: Styles.marginXS
                    spacing: Styles.marginSm

                    model: viewContainer.children
                    delegate: ButtonStyled {
                        id: tabButton

                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: tabButton.modelData.name
                        isFocused: root.currentTab === tabButton.index
                        defaultColor: theme.foreground
                        onClicked: {
                            root.currentTab = tabButton.index;
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: clock.implicitWidth + Styles.marginLg * 2
                        color: theme.background
                        radius: Styles.marginSm
                        TextStyled {
                            anchors.centerIn: parent
                            id: clock
                            text: Time.getTime() + ' | ' + Time.date
                        }
                    }
                }
            }

            Item {
                id: viewContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                focus: true
                TextClipboardView {
                    id: textView
                    property string name: Icons.copy
                    anchors.fill: parent
                    isActive: root.currentTab === 0 && root.visible
                    focus: isActive
                    onRequestExit: root.exit()
                    onRequestTabCycle: forward => root.cycleTab(forward)
                }

                ImageClipboardView {
                    id: imageView
                    property string name: Icons.image
                    anchors.fill: parent
                    isActive: root.currentTab === 1 && root.visible
                    focus: isActive
                }

                AsciiEmojisView {
                    id: emojiView
                    property string name: Icons.emoji
                    anchors.fill: parent
                    isActive: root.currentTab === 2 && root.visible
                    focus: isActive
                    onRequestExit: root.exit()
                }
            }
        }
    }
}
