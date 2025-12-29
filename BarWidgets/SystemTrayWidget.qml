pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Constants

Rectangle {
    id: root
    property int iconSize: 20
    property var currentOpenMenu: null
    radius: Styles.radiusSm
    color: Colors.background
    implicitHeight: parent.height
    implicitWidth: row.implicitWidth + Styles.marginSm * 2

    component AutoCloseTimerManager: QtObject {
        id: timerManager
        property Timer timer: Timer {
            interval: timerManager.currentInterval
            repeat: false
            onTriggered: {
                if (timerManager.onTimeout) {
                    timerManager.onTimeout();
                }
                timerManager.currentInterval = timerManager.initialInterval;
            }
        }
        property int initialInterval: 3000
        property int hoverInterval: 500
        property int currentInterval: initialInterval
        property var onTimeout: null
        function notifyHover() {
            if (currentInterval === initialInterval) {
                currentInterval = hoverInterval;
            }
            timer.stop();
        }
        function notifyUnhover() {
            timer.restart();
        }
    }

    component AnimatedMenuBackground: Rectangle {
        required property bool isVisible

        color: Colors.background
        radius: Styles.radiusLg
        opacity: isVisible ? 1 : 0
        scale: isVisible ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    component MenuButtonBase: ButtonStyled {
        required property AutoCloseTimerManager autoCloseTimer
        required property bool isEnabled
        required property string buttonText

        property int minWidth: 180

        Layout.fillWidth: true
        implicitWidth: Math.max(minWidth, buttonTextItem.implicitWidth + Styles.marginSm * 2)
        implicitHeight: buttonTextItem.implicitHeight + Styles.marginSm

        defaultColor: "transparent"
        hoverColor: Colors.bg2
        radius: Styles.radiusSm
        enabled: isEnabled
        opacity: isEnabled ? 1.0 : 0.5

        onContainsMouseChanged: {
            if (containsMouse) {
                autoCloseTimer.notifyHover();
            } else {
                autoCloseTimer.notifyUnhover();
            }
        }

        TextStyled {
            id: buttonTextItem
            text: buttonText
            font.pixelSize: Styles.textSm
            anchors.centerIn: parent
            color: isEnabled ? Colors.foreground : Colors.gray
        }
    }

    component SystemTrayMenu: PopupWindow {
        id: systemTrayMenu

        required property SystemTrayItem item

        implicitHeight: menuContent.implicitHeight + Styles.marginSm * 2
        implicitWidth: menuContent.implicitWidth + Styles.marginSm * 2

        color: "transparent"

        anchor {
            item: parent
            rect.y: parent.height + 10
            rect.x: parent.width / 2 - implicitWidth / 2
        }

        onVisibleChanged: {
            if (visible) {
                // Close any other open menu
                if (root.currentOpenMenu && root.currentOpenMenu !== systemTrayMenu) {
                    root.currentOpenMenu.visible = false;
                }
                root.currentOpenMenu = systemTrayMenu;
                autoCloseTimer.timer.restart();
            } else {
                if (root.currentOpenMenu === systemTrayMenu) {
                    root.currentOpenMenu = null;
                }
                autoCloseTimer.timer.stop();
            }
        }

        QsMenuOpener {
            id: menuOpener
            menu: systemTrayMenu.item.menu
        }

        AutoCloseTimerManager {
            id: autoCloseTimer
            onTimeout: function () {
                systemTrayMenu.visible = false;
            }
        }

        AnimatedMenuBackground {
            id: menuBackground
            anchors.fill: parent
            isVisible: systemTrayMenu.visible

            ColumnLayout {
                id: menuContent
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: 4

                Repeater {
                    model: menuOpener.children

                    Loader {
                        id: menuLoader
                        required property QsMenuEntry modelData

                        Layout.fillWidth: true

                        sourceComponent: modelData.isSeparator ? separatorComponent : menuItemComponent

                        Component {
                            id: separatorComponent
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 1
                                anchors.centerIn: parent
                                width: parent.width - Styles.marginSm * 2
                                color: Colors.bg2
                            }
                        }

                        Component {
                            id: menuItemComponent
                            Item {
                                id: menuItemWrapper
                                implicitWidth: menuButton.implicitWidth
                                implicitHeight: menuButton.implicitHeight

                                property bool submenuExpanded: false

                                ButtonStyled {
                                    id: menuButton

                                    anchors.fill: parent

                                    implicitWidth: Math.max(180, itemText.implicitWidth + Styles.marginSm * 2)
                                    implicitHeight: itemText.implicitHeight + Styles.marginSm

                                    defaultColor: "transparent"
                                    hoverColor: Colors.bg2
                                    radius: Styles.radiusSm

                                    enabled: menuLoader.modelData.enabled
                                    opacity: menuLoader.modelData.enabled ? 1.0 : 0.5

                                    onContainsMouseChanged: {
                                        if (containsMouse) {
                                            autoCloseTimer.notifyHover();
                                        } else {
                                            autoCloseTimer.notifyUnhover();
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: Styles.marginSm / 2
                                        spacing: Styles.marginSm

                                        IconImage {
                                            visible: menuLoader.modelData.icon !== undefined && menuLoader.modelData.icon !== null
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            source: menuLoader.modelData.icon || ""
                                        }

                                        TextStyled {
                                            id: itemText
                                            text: menuLoader.modelData.text || ""
                                            font.pixelSize: Styles.textSm
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            color: menuLoader.modelData.enabled ? Colors.foreground : Colors.gray
                                        }

                                        TextStyled {
                                            id: checkBox
                                            text: menuLoader.modelData.checkState === Qt.Checked ? "✓" : ""
                                            font.pixelSize: Styles.textSm
                                            color: Colors.green
                                            visible: menuLoader.modelData.buttonType !== 0
                                        }

                                        TextStyled {
                                            id: submenu
                                            text: "›"
                                            font.pixelSize: Styles.textSm
                                            color: Colors.gray
                                            visible: menuLoader.modelData.hasChildren
                                        }
                                    }

                                    onClicked: {
                                        if (menuLoader.modelData.enabled) {
                                            if (menuLoader.modelData.hasChildren) {
                                                menuItemWrapper.submenuExpanded = !menuItemWrapper.submenuExpanded;
                                            } else {
                                                menuLoader.modelData.triggered();
                                                systemTrayMenu.visible = false;
                                            }
                                        }
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                }

                                Loader {
                                    id: submenuLoader
                                    active: menuItemWrapper.submenuExpanded && menuLoader.modelData.hasChildren
                                    sourceComponent: PopupWindow {
                                        id: submenuPopup

                                        implicitHeight: submenuContent.implicitHeight + Styles.marginSm * 2
                                        implicitWidth: submenuContent.implicitWidth + Styles.marginSm * 2

                                        color: "transparent"
                                        visible: menuItemWrapper.submenuExpanded

                                        anchor {
                                            item: menuButton
                                            rect.x: menuButton.width + 5
                                            rect.y: 0
                                        }

                                        QsMenuOpener {
                                            id: submenuOpener
                                            menu: menuLoader.modelData
                                        }

                                        AnimatedMenuBackground {
                                            anchors.fill: parent
                                            isVisible: submenuPopup.visible

                                            ColumnLayout {
                                                id: submenuContent
                                                anchors.fill: parent
                                                anchors.margins: Styles.marginSm
                                                spacing: 4

                                                Repeater {
                                                    model: submenuOpener.children

                                                    MenuButtonBase {
                                                        id: submenuButton
                                                        required property var modelData

                                                        autoCloseTimer: autoCloseTimer
                                                        isEnabled: submenuButton.modelData.enabled
                                                        buttonText: submenuButton.modelData.text || ""

                                                        onClicked: {
                                                            if (submenuButton.modelData.enabled) {
                                                                submenuButton.modelData.triggered();
                                                                menuItemWrapper.submenuExpanded = false;
                                                                systemTrayMenu.visible = false;
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
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Styles.marginSm

        Repeater {
            id: trayRow
            model: SystemTray.items

            delegate: Item {
                id: trayItem
                required property SystemTrayItem modelData
                required property int index

                property int iconSize: root.iconSize
                property bool menuOpen: false

                implicitWidth: trayItem.iconSize + Styles.marginSm
                implicitHeight: trayItem.iconSize + Styles.marginSm

                ButtonStyled {
                    id: iconButton

                    anchors.fill: parent
                    defaultColor: Colors.bg1
                    hoverColor: Colors.bg2
                    radius: Styles.radiusSm

                    scale: trayItem.menuOpen ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    IconImage {
                        id: icon
                        anchors.centerIn: parent
                        width: trayItem.iconSize
                        height: trayItem.iconSize
                        source: trayItem.modelData.icon

                        opacity: iconButton.containsMouse ? 1.0 : 0.8

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    SystemTrayMenu {
                        id: trayMenu
                        item: trayItem.modelData
                        onVisibleChanged: {
                            trayItem.menuOpen = visible;
                        }
                    }

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton && trayItem.modelData.hasMenu) {
                            trayMenu.visible = !trayMenu.visible;
                        } else if (mouse.button === Qt.RightButton) {
                            trayItem.modelData.activate();
                        } else if (mouse.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
