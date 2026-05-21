pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick

FloatingWindow {
    id: root

    visible: false
    color: 'transparent'
    title: 'RabbitShell'

    required property Component delegate

    readonly property alias baseLoader: baseLoader

    property string shortcutName: ""

    function open() {
        root.visible = true;
    }

    function exit() {
        root.visible = false;
    }

    function toggle() {
        root.visible = !root.visible;
    }

    onClosed: root.exit()

    Loader {
        active: root.shortcutName !== ""
        sourceComponent: GlobalShortcut {
            name: root.shortcutName
            onPressed: root.toggle()
        }
    }

    HyprlandFocusGrab {
        id: grab
        active: root.visible
        windows: [root]
        onCleared: root.exit()
    }

    Loader {
        id: baseLoader
        anchors.fill: parent
        active: root.visible
        focus: true
        sourceComponent: root.delegate
    }
}
