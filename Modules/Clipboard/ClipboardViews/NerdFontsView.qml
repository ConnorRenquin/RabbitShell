pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Helpers
import qs.Components
import qs.Components.Plus
import qs.Components.Styled
import qs.Services

Rectangle {
    id: root

    color: "transparent"

    signal requestExit
    signal requestTabCycle(bool forward)

    visible: isActive
    property bool isActive: false
    focus: isActive

    property string searchText: ""
    property string selectedCategory: "all"
    property int selectedIndex: 0

    property var glyphs: []
    property var glyphMetadata: ({})
    property var categories: ["all"]

    property var filteredGlyphs: {
        const query = root.searchText.trim().toLowerCase();
        if (query === "" && root.selectedCategory === "all")
            return root.glyphs;

        let items = [];
        for (let i = 0; i < root.glyphs.length; i++) {
            const glyph = root.glyphs[i];
            if (root.selectedCategory !== "all" && glyph.category !== root.selectedCategory)
                continue;
            if (query === "") {
                items.push(glyph);
                continue;
            }
            const haystack = glyph.name + " " + glyph.category + " " + glyph.code + " " + glyph.aliases + " " + glyph.glyph;
            const result = utils.fuzzySearch(query, haystack.toLowerCase());
            if (result.matches) {
                items.push({
                    name: glyph.name,
                    glyph: glyph.glyph,
                    code: glyph.code,
                    category: glyph.category,
                    aliases: glyph.aliases,
                    score: result.score
                });
            }
        }

        if (query !== "")
            items.sort((a, b) => b.score - a.score);
        return items;
    }

    function navigationHandler(event) {
        if (controls.tabPressed(event)) {
            root.requestTabCycle(true);
            event.accepted = true;
            return true;
        }
        if (controls.backtabPressed(event)) {
            root.requestTabCycle(false);
            event.accepted = true;
            return true;
        }
        return false;
    }

    function copyGlyph(glyph, format = "glyph", closeAfter = true) {
        let value = glyph.glyph;
        if (format === "codepoint")
            value = "U+" + glyph.code.toUpperCase();
        else if (format === "css")
            value = "\\\\" + glyph.code.toLowerCase();

        ClipboardService.copyToClipboard(value, false);
        utils.notify({
            summary: "Copied: " + glyph.name,
            body: value
        });
        if (closeAfter)
            root.requestExit();
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(() => searchField.forceActiveFocus());
        }
    }

    FileViewPlus {
        path: Qt.resolvedUrl("NerdFontGlyphs.json")
        defaultValue: ({})

        onDataLoaded: data => {
            root.glyphMetadata = data.METADATA ?? {};
            const loadedGlyphs = [];
            const categorySet = {};
            const keys = Object.keys(data);
            for (let index = 0; index < keys.length; index++) {
                const key = keys[index];
                if (key === "METADATA")
                    continue;
                const value = data[key];
                const separator = key.indexOf("-");
                const category = separator === -1 ? "other" : key.substring(0, separator);
                const shortName = separator === -1 ? key : key.substring(separator + 1);
                categorySet[category] = true;
                loadedGlyphs.push({
                    name: shortName.replace(/_/g, " "),
                    glyph: value.char,
                    code: value.code,
                    category: category,
                    aliases: key.replace(/[-_]/g, " ")
                });
            }
            root.glyphs = loadedGlyphs;
            root.categories = ["all"].concat(Object.keys(categorySet).sort());
            root.selectedIndex = 0;
        }
    }

    Utils {
        id: utils
    }

    Controls {
        id: controls
    }

    Themer {
        id: theme
        settingName: 'clipboardColor'
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Styles.marginSm

        Rectangle {
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            Layout.margins: Styles.marginSm
            color: theme.foreground
            radius: Styles.radiusSm

            TextFieldStyled {
                id: searchField
                placeholderText: '/search nerdfont glyphs'
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                color: theme.text
                placeholderTextColor: theme.text
                onTextChanged: {
                    root.searchText = text;
                    root.selectedIndex = 0;
                }
                Keys.onPressed: event => {
                    if (root.navigationHandler(event)) return;
                    if (controls.escapePressed(event)) {
                        text = "";
                        glyphGrid.focus = true;
                        event.accepted = true;
                    }
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            Layout.leftMargin: Styles.marginSm
            Layout.rightMargin: Styles.marginSm
            orientation: ListView.Horizontal
            spacing: Styles.marginSm
            clip: true
            model: root.categories

            delegate: ButtonStyled {
                required property string modelData
                text: modelData === "all" ? "∞" : modelData
                implicitHeight: 30
                implicitWidth: Math.max(54, text.length * 9 + Styles.marginMd * 2)
                isFocused: root.selectedCategory === modelData
                defaultColor: isFocused ? theme.foreground : theme.background
                textColor: theme.text
                onClicked: {
                    root.selectedCategory = modelData;
                    root.selectedIndex = 0;
                }
            }
        }

        TextStyled {
            Layout.fillWidth: true
            Layout.leftMargin: Styles.marginSm
            Layout.rightMargin: Styles.marginSm
            text: root.filteredGlyphs.length + ' glyphs • right click: codepoint • middle click: CSS escape'
            color: theme.text
            font.pointSize: Styles.textSm
        }

        GridView {
            id: glyphGrid

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Styles.marginSm
            focus: true
            clip: true
            cellWidth: 180
            cellHeight: 148
            currentIndex: root.selectedIndex
            model: root.filteredGlyphs

            function select(index) {
                root.selectedIndex = Math.max(0, Math.min(root.filteredGlyphs.length - 1, index));
                positionViewAtIndex(root.selectedIndex, GridView.Contain);
            }

            Keys.onPressed: event => {
                if (root.navigationHandler(event))
                    return;
                if (controls.slashPressed(event)) {
                    searchField.forceActiveFocus();
                    event.accepted = true;
                } else if (controls.escapePressed(event)) {
                    root.requestExit();
                    event.accepted = true;
                } else if (controls.downPressed(event)) {
                    glyphGrid.select(root.selectedIndex + Math.max(1, Math.floor(glyphGrid.width / glyphGrid.cellWidth)));
                    event.accepted = true;
                } else if (controls.upPressed(event)) {
                    glyphGrid.select(root.selectedIndex - Math.max(1, Math.floor(glyphGrid.width / glyphGrid.cellWidth)));
                    event.accepted = true;
                } else if (controls.rightPressed(event)) {
                    glyphGrid.select(root.selectedIndex + 1);
                    event.accepted = true;
                } else if (controls.leftPressed(event)) {
                    glyphGrid.select(root.selectedIndex - 1);
                    event.accepted = true;
                } else if (controls.enterPressed(event) && root.filteredGlyphs[root.selectedIndex]) {
                    root.copyGlyph(root.filteredGlyphs[root.selectedIndex]);
                    event.accepted = true;
                }
            }

            delegate: ButtonStyled {
                id: glyphButton

                required property var modelData
                required property int index

                width: glyphGrid.cellWidth - Styles.marginSm
                height: glyphGrid.cellHeight - Styles.marginSm
                radius: Styles.radiusMd
                defaultColor: theme.background
                isFocused: root.selectedIndex === index

                onClicked: mouse => {
                    root.selectedIndex = index;
                    if (mouse.button === Qt.RightButton)
                        root.copyGlyph(modelData, "codepoint", false);
                    else if (mouse.button === Qt.MiddleButton)
                        root.copyGlyph(modelData, "css", false);
                    else
                        root.copyGlyph(modelData);
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginMd
                    spacing: Styles.marginSm

                    TextStyled {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: glyphButton.modelData.glyph
                        color: theme.text
                        font.pointSize: 34
                        font.family: Styles.defaultFontFamily
                    }

                    TextStyled {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: glyphButton.modelData.name
                        color: theme.text
                        font.pointSize: Styles.textSm
                        elide: Text.ElideRight
                    }

                    TextStyled {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: glyphButton.modelData.category + " • U+" + glyphButton.modelData.code.toUpperCase()
                        color: theme.text
                        font.pointSize: Styles.textXS
                        opacity: 0.8
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
