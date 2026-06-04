pragma ComponentBehavior: Bound

import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components
import qs.Components.Plus
import qs.Components.Styled
import qs.Services

FloatingWindowPlus {
    id: root

    title: 'Scratchpad Editor'
    shortcutName: "texteditor"

    property int currentTab: 0
    property var tabContents: ["", "", "", ""]
    property bool isReady: false

    property bool vimEnabled: textAreaItem ? textAreaItem.vimEnabled : false
    property string vimMode: textAreaItem ? textAreaItem.vimMode : 'NORMAL'
    readonly property var textAreaItem: root.baseLoader.item ? root.baseLoader.item.textAreaItem : null

    Component.onCompleted: PatchBay.openTextEditor.connect(open)

    function exit() {
        root.visible = false;
        saveTabs();
    }

    function open() {
        root.visible = true;
        if (textAreaItem && textAreaItem.vimEnabled) {
            textAreaItem.vimMode = 'NORMAL';
            textAreaItem.select(textAreaItem.cursorPosition, textAreaItem.cursorPosition);
        }
    }

    function cycleTab(forward: bool) {
        if (!textAreaItem) return;

        tabContents[currentTab] = textAreaItem.text;

        if (forward) {
            currentTab = (currentTab + 1) % 4;
        } else {
            currentTab = (currentTab + 3) % 4;
        }

        textAreaItem.text = tabContents[currentTab];
        textAreaItem.forceActiveFocus();
    }

    function selectTab(index: int) {
        if (index < 0 || index >= 4) return;
        if (!textAreaItem) return;

        tabContents[currentTab] = textAreaItem.text;
        currentTab = index;
        textAreaItem.text = tabContents[currentTab];
        textAreaItem.forceActiveFocus();
    }

    function saveTabs() {
        if (textAreaItem) {
            tabContents[currentTab] = textAreaItem.text;
        }
        persistantData.save({
            tabs: root.tabContents,
            lastActiveTab: root.currentTab
        });
    }

    FileViewPlus {
        id: persistantData
        path: Qt.resolvedUrl('../Settings/.data/text_editor_tabs.json')
        defaultValue: ({
            tabs: ["", "", "", ""],
            lastActiveTab: 0
        })

        onDataLoaded: parsed => {
            if (parsed.tabs && parsed.tabs.length === 4) {
                root.tabContents = parsed.tabs;
            }
            if (parsed.hasOwnProperty('lastActiveTab')) {
                root.currentTab = parsed.lastActiveTab;
            }
            if (textAreaItem) {
                textAreaItem.text = root.tabContents[root.currentTab];
            }
            root.isReady = true;
        }
    }

    delegate: Rectangle {
        id: base
        anchors.fill: parent
        color: Colors.background
        focus: true

        readonly property alias textAreaItem: textArea

        onVisibleChanged: {
            if (visible) {
                if (textArea.vimEnabled) {
                    textArea.vimMode = 'NORMAL';
                    textArea.select(textArea.cursorPosition, textArea.cursorPosition);
                }
                Qt.callLater(() => {
                    textArea.forceActiveFocus();
                });
            }
        }

        Component.onCompleted: {
            textArea.text = root.tabContents[root.currentTab];
            if (visible) {
                Qt.callLater(() => {
                    textArea.forceActiveFocus();
                });
            }
        }

        ColumnLayout {
            id: basePage
            anchors.fill: parent
            spacing: Styles.marginSm
            anchors.margins: Styles.marginSm
            RowLayoutPlus {
                id: tabBar
                Layout.preferredHeight: 45
                spacing: Styles.marginSm
                model: 4
                delegate: ButtonStyled {
                    id: tabButton
                    required property int index
                    text: (index + 1)
                    isFocused: root.currentTab === index
                    defaultColor: root.currentTab === index ? Colors.primary : Colors.surfaceVariant
                    textColor: root.currentTab === index ? Colors.onPrimary : Colors.onSurface
                    onClicked: {
                        root.selectTab(index);
                    }
                }
            }
            Rectangle {
                id: textBackground
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.darker(Colors.background, 1.2)
                radius: Styles.radiusSm
                ScrollView {
                    clip: true
                    anchors.fill: parent
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                    TextAreaPlus {
                        id: textArea

                        onTextChanged: {
                            if (root.isReady) {
                                root.tabContents[root.currentTab] = text;
                                root.saveTabs();
                            }
                        }

                        onRequestCycleTab: forward => root.cycleTab(forward)
                        onRequestSelectTab: index => root.selectTab(index)
                        onRequestExit: root.exit()
                    }
                }
            }

            // Footer / Status Bar
            Rectangle {
                id: statusBar
                Layout.fillWidth: true
                Layout.preferredHeight: 25
                color: root.vimEnabled ? (root.vimMode === 'NORMAL' ? Colors.primary : ((root.vimMode === 'VISUAL' || root.vimMode === 'VISUAL_LINE') ? Colors.tertiary : Colors.surface)) : Colors.surface
                radius: Styles.radiusSm

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Styles.marginMd
                    anchors.rightMargin: Styles.marginMd

                    TextStyled {
                        text: root.vimEnabled ? ("VIM: " + root.vimMode + " | i: insert | v/V: visual | Ctrl+Tab: cycle") : "Ctrl+Tab to cycle | Ctrl+1-4 to switch"
                        font.pointSize: Styles.textSm
                        color: root.vimEnabled && (root.vimMode === 'NORMAL' || root.vimMode === 'VISUAL' || root.vimMode === 'VISUAL_LINE') ? Colors.onPrimary : Colors.outline
                        Layout.fillWidth: true
                    }

                    TextStyled {
                        text: "Characters: " + (textAreaItem ? textAreaItem.text.length : 0)
                        font.pointSize: Styles.textSm
                        color: root.vimEnabled && (root.vimMode === 'NORMAL' || root.vimMode === 'VISUAL' || root.vimMode === 'VISUAL_LINE') ? Colors.onPrimary : Colors.outline
                    }
                }
            }
        }
    }
}
