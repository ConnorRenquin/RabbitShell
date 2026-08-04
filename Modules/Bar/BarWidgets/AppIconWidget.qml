pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import qs.Components.Plus
import qs.Components.Styled
import qs.Helpers
import qs.Settings

Item {
    id: root

    property var groupedToplevels: []

    Themer {
        id: theme
        settingName: 'appIconColor'
    }

    implicitWidth: icons.implicitWidth + Styles.marginSm

    function appIdFor(toplevel) {
        return toplevel?.wayland?.appId || "unknown";
    }

    function isValidToplevel(toplevel) {
        return !!toplevel?.wayland && appIdFor(toplevel) !== "unknown";
    }

    function appNameFor(toplevel) {
        const appId = appIdFor(toplevel);
        return DesktopEntries.byId(appId)?.name || appId;
    }

    function iconFor(toplevel) {
        return Quickshell.iconPath(DesktopEntries.byId(appIdFor(toplevel))?.icon, "applications-other");
    }

    function titleFor(toplevel) {
        return toplevel?.wayland?.title || appNameFor(toplevel);
    }

    function closeToplevel(toplevel) {
        const wayland = toplevel?.wayland;
        if (wayland?.close)
            wayland.close();
    }

    function normalizedHyprAddress(address) {
        const addressText = String(address || "");
        if (addressText.length === 0)
            return "";
        return addressText.startsWith("0x") ? addressText : "0x" + addressText;
    }

    function moveToplevelToCurrentWorkspace(toplevel) {
        const address = normalizedHyprAddress(toplevel?.address);
        const workspaceId = Hyprland.focusedWorkspace?.id;
        if (!address || workspaceId === undefined || workspaceId === null) {
            return;
        }
        const lua = 'hl.dsp.window.move({ workspace = "' + workspaceId + '", window = "address:' + address + '", silent = true })';
        Quickshell.execDetached(["hyprctl", "dispatch", lua]);
    }

    function updateGroups() {
        const groupsByAppId = {};
        const groups = [];

        for (const toplevel of Hyprland.toplevels?.values || []) {
            if (!isValidToplevel(toplevel))
                continue;

            const appId = appIdFor(toplevel);
            if (!groupsByAppId[appId]) {
                groupsByAppId[appId] = {
                    appId,
                    appName: appNameFor(toplevel),
                    icon: iconFor(toplevel),
                    toplevels: []
                };
                groups.push(groupsByAppId[appId]);
            }

            groupsByAppId[appId].toplevels.push(toplevel);
        }

        groupedToplevels = groups;
    }

    Component.onCompleted: updateGroups()

    Connections {
        target: Hyprland.toplevels
        function onValuesChanged() {
            root.updateGroups();
        }
    }

    RowLayoutPlus {
        id: icons
        anchors.centerIn: parent
        model: root.groupedToplevels
        delegate: ButtonStyled {
            required property var modelData

            id: button

            property bool popupOpen: false
            property var activeToplevel: modelData.toplevels.find(toplevel => toplevel.activated) || modelData.toplevels[0]
            readonly property bool hasActiveToplevel: modelData.toplevels.some(toplevel => toplevel.activated)

            radius: hasActiveToplevel ? Styles.marginLg : Styles.marginSm

            Layout.preferredWidth: 35
            Layout.preferredHeight: 32
            defaultColor: hasActiveToplevel ? theme.foreground : theme.background
            textColor: theme.text
            isFocused: hasActiveToplevel
            onClicked: activeToplevel?.wayland?.activate()
            onContainsMouseChanged: {
                if (containsMouse)
                    popupOpen = true;
                else
                    closePopupTimer.restart();
            }

            Behavior on radius {
                NumberAnimation {
                    duration: 250
                }
            }

            Timer {
                id: closePopupTimer
                interval: 350
                repeat: false
                onTriggered: {
                    if (!button.containsMouse && !popupHover.hovered)
                        button.popupOpen = false;
                }
            }

            IconImage {
                anchors.centerIn: parent
                implicitHeight: 24
                implicitWidth: 24
                source: button.modelData.icon
            }

            Rectangle {
                visible: button.modelData.toplevels.length > 1
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: 14
                height: 14
                radius: width / 2
                color: theme.foreground

                TextStyled {
                    anchors.centerIn: parent
                    text: button.modelData.toplevels.length
                    color: theme.text
                    font.pointSize: Styles.textXS
                }
            }

            PopupWindow {
                id: popup
                visible: button.popupOpen
                implicitWidth: 400
                implicitHeight: popupContent.implicitHeight + Styles.marginMd
                color: "transparent"

                anchor {
                    item: button
                    rect.x: button.width / 2 - popup.width / 2
                    rect.y: Settings.get('barPosition').value ? button.height + Styles.marginSm : -popup.height - Styles.marginSm
                }

                HoverHandler {
                    id: popupHover
                    onHoveredChanged: {
                        if (hovered)
                            button.popupOpen = true;
                        else
                            closePopupTimer.restart();
                    }
                }



                Rectangle {
                    anchors.fill: parent
                    radius: Styles.radiusMd
                    color: theme.background

                    ColumnLayout {
                        id: popupContent
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginXS

                        Repeater {
                            model: button.modelData.toplevels
                            delegate: Rectangle {
                                required property var modelData

                                id: windowButton

                                Layout.fillWidth: true
                                Layout.preferredWidth: 300
                                Layout.preferredHeight: 96
                                radius: Styles.radiusSm
                                color: windowButton.modelData.activated || hoverArea.containsMouse  ? Qt.lighter(theme.background, 1.3) : theme.background

                                MouseArea {
                                    id: hoverArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        windowButton.modelData.wayland.activate();
                                        button.popupOpen = false;
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Styles.marginSm
                                    anchors.rightMargin: Styles.marginSm
                                    spacing: Styles.marginSm

                                    Rectangle {
                                        Layout.preferredWidth: 128
                                        Layout.fillHeight: true
                                        radius: Styles.radiusSm
                                        color: theme.foreground
                                        clip: true

                                        ScreencopyView {
                                            id: preview
                                            anchors.fill: parent
                                            captureSource: popup.visible ? windowButton.modelData.wayland : null
                                            live: popup.visible
                                            paintCursor: false
                                        }

                                        IconImage {
                                            // visible: !preview.hasContent
                                            anchors.centerIn: parent
                                            implicitHeight: 28
                                            implicitWidth: 28
                                            source: root.iconFor(windowButton.modelData)
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Styles.marginXS

                                        TextStyled {
                                            Layout.fillWidth: true
                                            text: root.titleFor(windowButton.modelData)
                                            color: theme.text
                                            font.pointSize: Styles.textSm
                                        }

                                        TextStyled {
                                            Layout.fillWidth: true
                                            text: root.appNameFor(windowButton.modelData)
                                            color: theme.acent
                                            font.pointSize: Styles.textXS
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillHeight: true
                                        Layout.maximumWidth: 30
                                        Layout.minimumWidth: 30
                                        ButtonStyled {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            radius: Styles.radiusSm
                                            defaultColor: theme.acent
                                            text: Icons.close

                                            onClicked: mouse => {
                                                mouse.accepted = true;
                                                root.closeToplevel(windowButton.modelData);
                                                button.popupOpen = false;
                                            }
                                        }
                                        ButtonStyled {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            radius: Styles.radiusSm
                                            defaultColor: theme.acent
                                            text: Icons.moveWindow

                                            onClicked: mouse => {
                                                mouse.accepted = true;
                                                root.moveToplevelToCurrentWorkspace(windowButton.modelData);
                                                button.popupOpen = false;
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
    }
}
