import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Settings
import qs.Components

FloatingWindow {
    id: root

    implicitWidth: 1200
    implicitHeight: 800
    color: "transparent"

    visible: false

    GlobalShortcut {
        name: "cheatsheet"
        onPressed: root.visible = !root.visible
    }

    // Keybind sections data
    property var keybindSections: [
        {
            "title": "App Launcher",
            "icon": "󰘳",
            "keybinds": [
                {
                    "key": "Escape",
                    "action": "Clear input and close launcher"
                },
                {
                    "key": "Return / Enter",
                    "action": "Launch selected application"
                },
                {
                    "key": "↑",
                    "action": "Move up"
                },
                {
                    "key": "↓",
                    "action": "Move down"
                },
                {
                    "key": "←",
                    "action": "Move left"
                },
                {
                    "key": "→",
                    "action": "Move right"
                }
            ]
        },
        {
            "title": "Clipboard Manager",
            "icon": "",
            "keybinds": [
                {
                    "key": "/",
                    "action": "Activate search field"
                },
                {
                    "key": "Escape / Q",
                    "action": "Close clipboard manager"
                },
                {
                    "key": "↓ / J",
                    "action": "Move down in history"
                },
                {
                    "key": "↑ / K",
                    "action": "Move up in history"
                },
                {
                    "key": "Return / Enter",
                    "action": "Paste selected item"
                },
                {
                    "key": "G",
                    "action": "Go to top of list"
                },
                {
                    "key": "D",
                    "action": "Delete current item"
                },
                {
                    "key": "0-9",
                    "action": "Quick paste from slot"
                },
                {
                    "key": "Ctrl + 0-9",
                    "action": "Store item to slot"
                },
                {
                    "key": "Alt + D",
                    "action": "Clear all slots"
                }
            ]
        },
        {
            "title": "Mixer",
            "icon": "󰕾",
            "keybinds": [
                {
                    "key": "Escape / Q",
                    "action": "Close mixer"
                },
                {
                    "key": "↓ / J",
                    "action": "Next audio device"
                },
                {
                    "key": "↑ / K",
                    "action": "Previous audio device"
                },
                {
                    "key": "← / H",
                    "action": "Decrease volume (5%)"
                },
                {
                    "key": "→ / L",
                    "action": "Increase volume (5%)"
                },
                {
                    "key": "M",
                    "action": "Toggle mute"
                }
            ]
        },
        {
            "title": "Notification Manager",
            "icon": "󰂚",
            "keybinds": [
                {
                    "key": "Escape / Q",
                    "action": "Close notification manager"
                },
                {
                    "key": "C",
                    "action": "Clear all notifications"
                }
            ]
        },
        {
            "title": "Power Menu",
            "icon": "󰐥",
            "keybinds": [
                {
                    "key": "Escape / Q",
                    "action": "Close power menu"
                },
                {
                    "key": "↓ / J",
                    "action": "Next option"
                },
                {
                    "key": "↑ / K",
                    "action": "Previous option"
                },
                {
                    "key": "Return / Enter",
                    "action": "Execute selected action"
                }
            ]
        },
        {
            "title": "Toplevel View",
            "icon": "󰖯",
            "keybinds": [
                {
                    "key": "Escape / Q",
                    "action": "Close toplevel view"
                },
                {
                    "key": "Letter Keys",
                    "action": "Jump to window starting with that letter"
                }
            ]
        },
        {
            "title": "Workspace Switcher",
            "icon": "",
            "keybinds": [
                {
                    "key": "Escape / Q",
                    "action": "Close workspace switcher"
                },
                {
                    "key": "Letter Keys",
                    "action": "Switch to workspace mapped to that letter"
                }
            ]
        },
        {
            "title": "Polkit",
            "icon": "󰌾",
            "keybinds": [
                {
                    "key": "Escape",
                    "action": "Cancel authentication"
                }
            ]
        }
    ]

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        border.color: Colors.gray

        ColumnLayout {
            anchors.fill: parent

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Colors.background

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20

                    TextStyled {
                        text: "󰌌 Keybind Cheatsheet"
                        Layout.fillWidth: true
                    }
                }
            }

            // Grid Content
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Styles.marginSm

                clip: true

                GridView {
                    id: gridView
                    cellWidth: parent.width / 2
                    cellHeight: 400
                    model: root.keybindSections

                    delegate: Rectangle {
                        implicitWidth: gridView.cellWidth - Styles.marginSm
                        implicitHeight: gridView.cellHeight - Styles.marginSm
                        color: Colors.backgroundLifted
                        radius: Styles.radiusSm

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Styles.marginSm
                            spacing: Styles.marginSm
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                TextStyled {
                                    text: modelData.icon
                                }

                                TextStyled {
                                    text: modelData.title
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: Colors.foreground
                            }

                            // Keybinds List
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                Column {
                                    width: parent.width
                                    spacing: Styles.marginSm

                                    Repeater {
                                        model: modelData.keybinds

                                        RowLayout {
                                            width: parent.width
                                            spacing: 10

                                            Rectangle {
                                                Layout.preferredWidth: contentWidth + 12
                                                Layout.preferredHeight: 24
                                                color: Colors.backgroundHighlighted
                                                radius: 4
                                                border.color: Colors.gray
                                                border.width: 1

                                                property real contentWidth: keyText.implicitWidth

                                                TextStyled {
                                                    id: keyText
                                                    anchors.centerIn: parent
                                                    text: modelData.key
                                                }
                                            }

                                            TextStyled {
                                                text: modelData.action
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                root.visible = false;
            }
        }

        Component.onCompleted: forceActiveFocus()
    }
}
