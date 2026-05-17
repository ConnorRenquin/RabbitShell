pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root
    required property string monitorName

    Themer {
        id: theme
        settingName: 'workspacesColor'
    }

    radius: Styles.radiusSm
    color: Colors.surface
    implicitHeight: parent.height
    implicitWidth: workspacesListView.width + Styles.marginSm

    NumberAnimation on implicitWidth {
        duration: 150
    }

    ListView {
        id: workspacesListView
        orientation: ListView.Horizontal
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: Styles.marginSm / 2
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: root.height - Styles.marginSm
        implicitWidth: Math.min(212, contentWidth)
        interactive: true
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        model: Hyprland.workspaces.values.filter(workspace => workspace.id != -99 && workspace.monitor?.name == root.monitorName)

        // Track the focused workspace and position view to show it
        property int focusedIndex: {
            for (let i = 0; i < count; i++) {
                let item = model[i];
                if (item && item.focused) {
                    return i;
                }
            }
            return -1;
        }

        onFocusedIndexChanged: {
            if (focusedIndex !== -1) {
                currentIndex = focusedIndex;
                positionViewAtIndex(focusedIndex, ListView.Center);
            }
        }

        delegate: ButtonStyled {
            id: workspaceButton
            required property HyprlandWorkspace modelData

            implicitHeight: root.height - Styles.marginSm
            implicitWidth: workspaceIcon.implicitWidth + Styles.marginSm
            radius: modelData?.focused ? Styles.radiusLg : Styles.radiusSm

            onClicked: Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({ workspace = "${modelData.id}" })`])

            NumberAnimation on radius {
                duration: 400
                easing.type: Easing.OutQuad
            }

            DoubleText {
                id: workspaceIcon
                elide: Text.ElideNone
                primaryColor: theme.main
                anchors.centerIn: parent
                text: workspaceButton.modelData?.focused ? "󰜋" : "󰜌"
            }
        }
    }
}
