pragma ComponentBehavior: Bound

import Quickshell.Io

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel

import qs.Settings
import qs.Components

Rectangle {
    id: root

    anchors.fill: parent
    color: Qt.lighter(Colors.surface, Colors.lighter)

    readonly property url docsDirectory: Qt.resolvedUrl("../../docs")
    property int currentTabIndex: 0
    property url currentDocUrl: ""

    Component.onCompleted: forceActiveFocus()

    function selectDocument(index) {
        if (index < 0 || index >= docsModel.count) {
            return;
        }

        currentTabIndex = index;
        currentDocUrl = docsModel.get(index, "fileUrl");
    }

    FolderListModel {
        id: docsModel
        folder: root.docsDirectory
        rootFolder: root.docsDirectory
        nameFilters: ["*.md"]
        showDirs: false

        onCountChanged: {
            if (count > 0 && (root.currentDocUrl.toString() === "" || root.currentTabIndex >= count)) {
                root.selectDocument(0);
            } else if (count === 0) {
                root.currentTabIndex = 0;
                root.currentDocUrl = "";
                cheatsheetText.text = "No documentation files found in `docs`.";
            }
        }
    }

    FileView {
        id: cheatsheetFile
        path: root.currentDocUrl
        blockLoading: false

        onLoaded: cheatsheetText.text = cheatsheetFile.text()
        onLoadFailed: cheatsheetText.text = "Failed to load `" + root.currentDocUrl + "`."
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        ScrollView {
            id: tabScrollView
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            contentHeight: availableHeight
            visible: docsModel.count > 1
            clip: true

            ListView {
                id: tabList
                width: tabScrollView.availableWidth
                height: tabScrollView.availableHeight
                orientation: ListView.Horizontal
                spacing: Styles.marginSm
                model: docsModel
                boundsBehavior: Flickable.StopAtBounds

                delegate: ButtonStyled {
                    id: tabButton

                    required property string fileName
                    required property url fileUrl
                    required property int index

                    height: tabList.height
                    width: Math.max(tabText.implicitWidth + Styles.marginLg, 120)
                    text: ""
                    isFocused: root.currentTabIndex === index

                    onClicked: root.selectDocument(index)

                    TextStyled {
                        id: tabText
                        anchors.centerIn: parent
                        text: tabButton.fileName
                        font.bold: root.currentTabIndex === tabButton.index
                    }
                }
            }
        }

        ScrollView {
            id: mainScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            TextStyled {
                id: cheatsheetText
                width: mainScrollView.availableWidth
                textFormat: Text.MarkdownText
                wrapMode: Text.WordWrap
            }
        }
    }
}
