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

    property string shortcutName: ""

    property int windowWidth: 0
    property int windowHeight: 0
    property int windowImplicitWidth: 0
    property int windowImplicitHeight: 0

    width: windowWidth > 0 ? windowWidth : undefined
    height: windowHeight > 0 ? windowHeight : undefined
    implicitWidth: windowImplicitWidth > 0 ? windowImplicitWidth : undefined
    implicitHeight: windowImplicitHeight > 0 ? windowImplicitHeight : undefined

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
        anchors.fill: parent
        active: root.visible
        focus: true
        sourceComponent: root.delegate
    }
}
