pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import qs.Components.Plus
import qs.Components.Styled
import qs.Settings

Item {
    id: root

    property var groupedToplevels: []

    implicitWidth: icons.implicitWidth + Styles.marginSm

    function appIdFor(toplevel) {
        return toplevel?.wayland?.appId || "unknown";
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

    function updateGroups() {
        const groupsByAppId = {};
        const groups = [];

        for (const toplevel of Hyprland.toplevels?.values || []) {
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

            Layout.preferredWidth: 35
            Layout.preferredHeight: 32
            onClicked: activeToplevel?.wayland?.activate()
            onContainsMouseChanged: {
                if (containsMouse)
                    popupOpen = true;
                else
                    closePopupTimer.restart();
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
                color: Colors.surfaceVariant

                TextStyled {
                    anchors.centerIn: parent
                    text: button.modelData.toplevels.length
                    font.pointSize: Styles.textXS
                }
            }

            PopupWindow {
                id: popup
                visible: button.popupOpen
                implicitWidth: 260
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
                    color: Colors.background

                    ColumnLayout {
                        id: popupContent
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginXS

                        Repeater {
                            model: button.modelData.toplevels
                            delegate: ButtonStyled {
                                required property var modelData

                                id: windowButton

                                Layout.fillWidth: true
                                Layout.preferredWidth: 240
                                Layout.preferredHeight: 36
                                onClicked: {
                                    windowButton.modelData.wayland.activate();
                                    button.popupOpen = false;
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Styles.marginSm
                                    anchors.rightMargin: Styles.marginSm
                                    spacing: Styles.marginSm

                                    IconImage {
                                        implicitHeight: 22
                                        implicitWidth: 22
                                        source: root.iconFor(windowButton.modelData)
                                    }

                                    TextStyled {
                                        Layout.fillWidth: true
                                        text: root.titleFor(windowButton.modelData)
                                        font.pointSize: Styles.textSm
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
