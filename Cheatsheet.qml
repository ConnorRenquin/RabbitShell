pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Settings
import qs.Components

Rectangle {
    id: root

    anchors.fill: parent
    color: Colors.backgroundLifted

    Component.onCompleted: forceActiveFocus()

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

    ScrollView {
        id: mainScrollView
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayoutPlus {
            id: gridView
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            model: root.keybindSections
            delegate: Rectangle {
                id: sectionRect

                required property int index
                required property var modelData

                Layout.fillWidth: true
                // Layout.fillHeight: true
                Layout.preferredHeight: contentColumn.implicitHeight + 2 * Styles.marginMd
                Layout.minimumWidth: 300
                color: Colors.background
                radius: Styles.radiusSm

                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    anchors.margins: Styles.marginMd
                    spacing: Styles.marginMd

                    // Header row with icon and title
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Styles.marginSm

                        TextStyled {
                            text: sectionRect.modelData.icon
                            font.pixelSize: 18
                        }

                        TextStyled {
                            text: sectionRect.modelData.title
                            font.bold: true
                            Layout.fillWidth: true
                        }
                    }

                    // Keybinds list
                    ListView {
                        id: keybindsList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        implicitHeight: contentHeight
                        spacing: Styles.marginSm
                        clip: true
                        interactive: false

                        model: sectionRect.modelData.keybinds

                        delegate: RowLayout {
                            required property int index
                            required property var modelData

                            width: keybindsList.width
                            spacing: Styles.marginSm

                            Rectangle {
                                Layout.preferredWidth: keyText.implicitWidth + 12
                                Layout.preferredHeight: 24
                                color: Colors.backgroundHighlighted
                                radius: Styles.radiusSm

                                TextStyled {
                                    id: keyText
                                    anchors.centerIn: parent
                                    text: modelData.key
                                }
                            }

                            TextStyled {
                                text: modelData.action
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }
        }
    }
}
