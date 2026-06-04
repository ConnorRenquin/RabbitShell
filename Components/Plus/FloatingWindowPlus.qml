pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick

FloatingWindow {
    id: root

    reloadableId: "floating-window-plus-" + persistId
    visible: false
    color: 'transparent'
    title: 'RabbitShell'

    required property Component delegate

    readonly property alias baseLoader: baseLoader

    property string shortcutName: ""
    property string persistId: title
    property bool focusGrabEnabled: true
    property bool contentFocusEnabled: true

    PersistentProperties {
        id: persisted
        reloadableId: "floating-window-plus-" + root.persistId

        property bool wasVisible: false

        function restoreVisibility() {
            if (wasVisible)
                Qt.callLater(root.open);
        }

        onLoaded: restoreVisibility()
        onReloaded: restoreVisibility()
    }

    function open() {
        persisted.wasVisible = true;
        root.visible = true;
    }

    function exit() {
        persisted.wasVisible = false;
        root.visible = false;
    }

    function toggle() {
        if (root.visible)
            root.exit();
        else
            root.open();
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
        active: root.focusGrabEnabled && root.visible
        windows: [root]
        onCleared: root.exit()
    }

    Loader {
        id: baseLoader
        anchors.fill: parent
        active: root.visible
        focus: root.contentFocusEnabled
        sourceComponent: root.delegate
    }
}
