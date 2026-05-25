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

    required property string name

    anchors.fill: parent
    color: Qt.lighter(Colors.surface, Colors.lighter)

    readonly property url docsDirectory: Qt.resolvedUrl("../../docs")
    property int currentTabIndex: 0
    property url currentDocUrl: ""
    property string renderedTitle: ""
    property var renderedSections: []

    readonly property int cardMinWidth: 420
    readonly property color codeBackground: Colors.surface
    readonly property color codeForeground: Colors.primary
    readonly property string codeBackgroundCss: codeBackground.toString()
    readonly property string codeForegroundCss: codeForeground.toString()

    Component.onCompleted: forceActiveFocus()

    function escapeHtml(value) {
        return String(value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/\"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

    function renderInlineMarkdown(value) {
        return escapeHtml(value).replace(/`([^`]+)`/g, "<span style='font-family:&quot;" + Styles.defaultFontFamily + "&quot;; font-weight:800; color:" + root.codeForegroundCss + "; background-color:" + root.codeBackgroundCss + ";'>&nbsp;$1&nbsp;</span>");
    }

    function renderCodeBlock(value) {
        return "<table width='100%' cellspacing='0' cellpadding='" + Styles.marginSm + "' style='margin:" + Styles.marginSm + "px 0 " + Styles.marginMd + "px " + Styles.marginSm + "px;'><tr><td bgcolor='" + root.codeBackgroundCss + "'><pre style='margin:0; line-height:130%; font-family:&quot;" + Styles.defaultFontFamily + "&quot;; font-size:" + Styles.textMd + "pt; font-weight:700; color:" + root.codeForegroundCss + ";'>" + escapeHtml(value) + "</pre></td></tr></table>";
    }

    function renderMarkdown(markdown) {
        var lines = String(markdown).replace(/\r\n/g, "\n").split("\n");
        var html = "<div style='color:" + Colors.onSurface + "; font-family:&quot;" + Styles.defaultFontFamily + "&quot;; font-size:" + Styles.textMd + "pt;'>";
        var inShortcutGroup = false;
        var inCodeBlock = false;
        var codeBlock = [];

        function closeShortcutGroup() {
            if (inShortcutGroup) {
                html += "</div>";
                inShortcutGroup = false;
            }
        }

        for (var i = 0; i < lines.length; i++) {
            var rawLine = lines[i];
            var line = rawLine.trim();

            if (line.startsWith("```")) {
                closeShortcutGroup();

                if (inCodeBlock) {
                    html += renderCodeBlock(codeBlock.join("\n"));
                    codeBlock = [];
                    inCodeBlock = false;
                } else {
                    inCodeBlock = true;
                }
                continue;
            }

            if (inCodeBlock) {
                codeBlock.push(rawLine);
                continue;
            }

            if (line.length === 0) {
                closeShortcutGroup();
                continue;
            }

            if (line.startsWith("# ")) {
                closeShortcutGroup();
                html += "<h1 style='margin:0 0 " + Styles.marginSm + "px 0; font-size:" + (Styles.textLg * 1.25) + "pt; font-weight:900; color:" + Colors.onSurface + ";'>" + renderInlineMarkdown(line.slice(2)) + "</h1>";
                continue;
            }

            if (line.startsWith("## ")) {
                closeShortcutGroup();
                html += "<h2 style='margin:" + Styles.marginMd + "px 0 " + Styles.marginSm + "px 0; font-size:" + Styles.textLg + "pt; font-weight:800; color:" + Colors.primary + ";'>" + renderInlineMarkdown(line.slice(3)) + "</h2>";
                continue;
            }

            var shortcut = line.match(/^`([^`]+)`\s+-\s+(.*)$/);
            if (shortcut) {
                if (!inShortcutGroup) {
                    html += "<div style='margin:0 0 " + Styles.marginSm + "px " + Styles.marginSm + "px;'>";
                    inShortcutGroup = true;
                }

                html += "<table cellspacing='0' cellpadding='0' style='margin:" + Styles.marginXS + "px 0; line-height:130%;'><tr>"
                    + "<td bgcolor='" + root.codeBackgroundCss + "' style='color:" + root.codeForegroundCss + "; font-family:&quot;" + Styles.defaultFontFamily + "&quot;; font-weight:800;'>&nbsp;" + escapeHtml(shortcut[1]) + "&nbsp;</td>"
                    + "<td style='color:" + Colors.onSurfaceVariant + ";'>&nbsp;—&nbsp;</td>"
                    + "<td style='font-weight:600; color:" + Colors.onSurface + ";'>" + renderInlineMarkdown(shortcut[2]) + "</td>"
                    + "</tr></table>";
                continue;
            }

            closeShortcutGroup();
            html += "<p style='margin:" + Styles.marginSm + "px 0; line-height:130%;'>" + renderInlineMarkdown(line) + "</p>";
        }

        if (inCodeBlock) {
            closeShortcutGroup();
            html += renderCodeBlock(codeBlock.join("\n"));
        }

        closeShortcutGroup();
        html += "</div>";
        return html;
    }

    function makeSectionData(sectionTitle, sectionHtml) {
        return sectionTitle + "|||" + sectionHtml;
    }

    function sectionTitle(sectionData) {
        var separatorIndex = String(sectionData).indexOf("|||");
        return separatorIndex < 0 ? "" : String(sectionData).slice(0, separatorIndex);
    }

    function sectionContent(sectionData) {
        var separatorIndex = String(sectionData).indexOf("|||");
        return separatorIndex < 0 ? String(sectionData) : String(sectionData).slice(separatorIndex + 3);
    }

    function sectionWeight(sectionData) {
        var plainText = sectionContent(sectionData).replace(/<[^>]*>/g, " ");
        var shortcutCount = Math.max(1, plainText.split("—").length - 1);
        return plainText.length + shortcutCount * 80;
    }

    function sectionsForColumn(columnIndex, columnCount) {
        var columns = [];
        var weights = [];

        for (var column = 0; column < columnCount; column++) {
            columns.push([]);
            weights.push(0);
        }

        for (var sectionIndex = 0; sectionIndex < renderedSections.length; sectionIndex++) {
            var targetColumn = 0;
            for (var weightIndex = 1; weightIndex < weights.length; weightIndex++) {
                if (weights[weightIndex] < weights[targetColumn]) {
                    targetColumn = weightIndex;
                }
            }

            columns[targetColumn].push(renderedSections[sectionIndex]);
            weights[targetColumn] += sectionWeight(renderedSections[sectionIndex]);
        }

        return columns[columnIndex] || [];
    }

    function appendRenderedSection(sections, sectionTitle, sectionLines) {
        var sectionBody = sectionLines.join("\n").trim();
        if (sectionTitle === "" && sectionBody === "") {
            return;
        }

        sections.push(makeSectionData(sectionTitle, renderMarkdown(sectionBody)));
    }

    function renderDocument(markdown) {
        var lines = String(markdown).replace(/\r\n/g, "\n").split("\n");
        var title = "Cheatsheet";
        var sections = [];
        var currentTitle = "";
        var currentLines = [];

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            var trimmed = line.trim();

            if (trimmed.startsWith("# ")) {
                title = renderInlineMarkdown(trimmed.slice(2));
                continue;
            }

            if (trimmed.startsWith("## ")) {
                appendRenderedSection(sections, currentTitle, currentLines);
                currentTitle = renderInlineMarkdown(trimmed.slice(3));
                currentLines = [];
                continue;
            }

            currentLines.push(line);
        }

        appendRenderedSection(sections, currentTitle, currentLines);

        if (sections.length === 0) {
            var fallbackLines = [];
            fallbackLines.push(markdown);
            appendRenderedSection(sections, "", fallbackLines);
        }

        root.renderedTitle = title;
        root.renderedSections = sections;
    }

    FolderListModel {
        id: docsModel
        folder: root.docsDirectory
        rootFolder: root.docsDirectory
        nameFilters: ["*.md"]
        showDirs: false

        onCountChanged: {
            if (count > 0 && (root.currentDocUrl.toString() === "" || root.currentTabIndex >= count)) {
                root.currentTabIndex = 0;
                root.currentDocUrl = docsModel.get(0, "fileUrl");
            } else if (count === 0) {
                root.currentTabIndex = 0;
                root.currentDocUrl = "";
                root.renderDocument("# Cheatsheet\n\nNo documentation files found in `docs`.");
            }
        }
    }

    FileView {
        id: cheatsheetFile
        path: root.currentDocUrl
        blockLoading: false

        onLoaded: root.renderDocument(cheatsheetFile.text())
        onLoadFailed: root.renderDocument("# Cheatsheet\n\nFailed to load `" + root.currentDocUrl + "`.")
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

                    onClicked: {
                        root.currentTabIndex = index;
                        root.currentDocUrl = fileUrl;
                    }

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
            contentHeight: cheatsheetContent.implicitHeight
            clip: true

            ColumnLayout {
                id: cheatsheetContent
                width: mainScrollView.availableWidth
                spacing: Styles.marginMd

                TextStyled {
                    id: cheatsheetTitle
                    Layout.fillWidth: true
                    text: root.renderedTitle
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    elide: Text.ElideNone
                    font.pointSize: Styles.textLg * 1.25
                    font.bold: true
                    color: Colors.onSurface
                }

                RowLayout {
                    id: sectionColumns

                    readonly property int columnCount: Math.max(1, Math.floor((width + spacing) / (root.cardMinWidth + spacing)))

                    Layout.fillWidth: true
                    spacing: Styles.marginMd

                    Repeater {
                        model: sectionColumns.columnCount

                        delegate: ColumnLayout {
                            id: masonryColumn

                            required property int index
                            property var columnSections: root.sectionsForColumn(index, sectionColumns.columnCount)

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            spacing: Styles.marginMd

                            Repeater {
                                model: masonryColumn.columnSections

                                delegate: Rectangle {
                                    id: sectionCard

                                    required property var modelData

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: sectionColumn.implicitHeight + Styles.marginMd
                                    color: Qt.lighter(Colors.surface, 1.15)
                                    radius: Styles.radiusMd
                                    border.width: 1
                                    border.color: Colors.outlineVariant

                                    ColumnLayout {
                                        id: sectionColumn
                                        anchors.fill: parent
                                        anchors.margins: Styles.marginSm
                                        spacing: Styles.marginSm

                                        TextStyled {
                                            Layout.fillWidth: true
                                            visible: root.sectionTitle(sectionCard.modelData) !== ""
                                            text: root.sectionTitle(sectionCard.modelData)
                                            textFormat: Text.RichText
                                            wrapMode: Text.WordWrap
                                            elide: Text.ElideNone
                                            color: Colors.primary
                                            font.pointSize: Styles.textLg
                                            font.bold: true
                                        }

                                        TextStyled {
                                            Layout.fillWidth: true
                                            text: root.sectionContent(sectionCard.modelData)
                                            textFormat: Text.RichText
                                            wrapMode: Text.WordWrap
                                            elide: Text.ElideNone
                                            font.pointSize: Styles.textMd
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
