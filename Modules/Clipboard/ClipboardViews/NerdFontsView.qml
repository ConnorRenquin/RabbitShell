pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Helpers
import qs.Components
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
    property int selectedIndex: 0

    property var glyphs: [
        {name: "linux", glyph: "", code: "f17c", category: "os", aliases: "tux unix"},
        {name: "arch linux", glyph: "", code: "f303", category: "os", aliases: "archlinux distro"},
        {name: "nixos", glyph: "", code: "f313", category: "os", aliases: "nix snowflake"},
        {name: "ubuntu", glyph: "", code: "f31b", category: "os", aliases: "distro"},
        {name: "debian", glyph: "", code: "f306", category: "os", aliases: "distro"},
        {name: "fedora", glyph: "", code: "f30a", category: "os", aliases: "distro"},
        {name: "windows", glyph: "", code: "f17a", category: "os", aliases: "microsoft"},
        {name: "apple", glyph: "", code: "f179", category: "os", aliases: "mac macos"},
        {name: "android", glyph: "", code: "f17b", category: "os", aliases: "phone"},

        {name: "folder", glyph: "", code: "f07b", category: "files", aliases: "directory"},
        {name: "folder open", glyph: "", code: "f07c", category: "files", aliases: "directory open"},
        {name: "file", glyph: "", code: "f15b", category: "files", aliases: "document"},
        {name: "file code", glyph: "", code: "f1c9", category: "files", aliases: "source programming"},
        {name: "file image", glyph: "", code: "f1c5", category: "files", aliases: "picture png jpg"},
        {name: "file archive", glyph: "", code: "f1c6", category: "files", aliases: "zip tar compressed"},
        {name: "download", glyph: "", code: "f019", category: "files", aliases: "save"},
        {name: "upload", glyph: "", code: "f093", category: "files", aliases: "send"},
        {name: "copy", glyph: "", code: "f0c5", category: "files", aliases: "duplicate clipboard"},
        {name: "trash", glyph: "", code: "f1f8", category: "files", aliases: "delete remove"},

        {name: "git", glyph: "", code: "e702", category: "dev", aliases: "version control"},
        {name: "github", glyph: "", code: "f09b", category: "dev", aliases: "octocat"},
        {name: "git branch", glyph: "", code: "e725", category: "dev", aliases: "fork vcs"},
        {name: "terminal", glyph: "", code: "f120", category: "dev", aliases: "console shell cli"},
        {name: "code", glyph: "", code: "f121", category: "dev", aliases: "programming brackets"},
        {name: "bug", glyph: "", code: "f188", category: "dev", aliases: "debug issue"},
        {name: "package", glyph: "", code: "f487", category: "dev", aliases: "box npm crate"},
        {name: "database", glyph: "", code: "f1c0", category: "dev", aliases: "sql storage"},
        {name: "docker", glyph: "", code: "f308", category: "dev", aliases: "container"},
        {name: "nodejs", glyph: "", code: "e718", category: "dev", aliases: "javascript node"},
        {name: "python", glyph: "", code: "e73c", category: "dev", aliases: "py"},
        {name: "rust", glyph: "", code: "e7a8", category: "dev", aliases: "cargo crab"},
        {name: "lua", glyph: "", code: "e620", category: "dev", aliases: "script"},
        {name: "javascript", glyph: "", code: "e74e", category: "dev", aliases: "js"},
        {name: "typescript", glyph: "", code: "e628", category: "dev", aliases: "ts"},
        {name: "html5", glyph: "", code: "f13b", category: "dev", aliases: "web html"},
        {name: "css3", glyph: "", code: "f13c", category: "dev", aliases: "web css"},

        {name: "wifi", glyph: "", code: "f1eb", category: "system", aliases: "network wireless"},
        {name: "ethernet", glyph: "󰈀", code: "f0200", category: "system", aliases: "network wired lan"},
        {name: "bluetooth", glyph: "", code: "f293", category: "system", aliases: "wireless"},
        {name: "volume high", glyph: "", code: "f028", category: "system", aliases: "audio sound speaker"},
        {name: "volume muted", glyph: "", code: "f6a9", category: "system", aliases: "audio sound mute"},
        {name: "battery full", glyph: "", code: "f240", category: "system", aliases: "power charge"},
        {name: "battery half", glyph: "", code: "f242", category: "system", aliases: "power charge"},
        {name: "plug", glyph: "", code: "f1e6", category: "system", aliases: "power charging"},
        {name: "desktop", glyph: "", code: "f108", category: "system", aliases: "monitor display"},
        {name: "keyboard", glyph: "", code: "f11c", category: "system", aliases: "input keys"},
        {name: "mouse", glyph: "󰍽", code: "f037d", category: "system", aliases: "input pointer"},
        {name: "memory", glyph: "", code: "efc5", category: "system", aliases: "ram"},
        {name: "cpu", glyph: "", code: "f4bc", category: "system", aliases: "processor chip"},
        {name: "hard drive", glyph: "", code: "f0a0", category: "system", aliases: "disk storage"},

        {name: "home", glyph: "", code: "f015", category: "ui", aliases: "house"},
        {name: "settings", glyph: "", code: "f013", category: "ui", aliases: "gear cog config"},
        {name: "search", glyph: "", code: "f002", category: "ui", aliases: "find magnify"},
        {name: "heart", glyph: "", code: "f004", category: "ui", aliases: "love favorite"},
        {name: "star", glyph: "", code: "f005", category: "ui", aliases: "favorite"},
        {name: "check", glyph: "", code: "f00c", category: "ui", aliases: "ok done"},
        {name: "close", glyph: "", code: "f00d", category: "ui", aliases: "x cancel"},
        {name: "plus", glyph: "", code: "f067", category: "ui", aliases: "add"},
        {name: "minus", glyph: "", code: "f068", category: "ui", aliases: "remove"},
        {name: "warning", glyph: "", code: "f071", category: "ui", aliases: "alert"},
        {name: "info", glyph: "", code: "f05a", category: "ui", aliases: "information"},
        {name: "lock", glyph: "", code: "f023", category: "ui", aliases: "secure"},
        {name: "unlock", glyph: "", code: "f09c", category: "ui", aliases: "open"},
        {name: "calendar", glyph: "", code: "f073", category: "ui", aliases: "date"},
        {name: "clock", glyph: "", code: "f017", category: "ui", aliases: "time"},
        {name: "bell", glyph: "", code: "f0f3", category: "ui", aliases: "notification"},
        {name: "power", glyph: "", code: "f011", category: "ui", aliases: "shutdown"},

        {name: "arrow up", glyph: "", code: "f062", category: "arrows", aliases: "direction"},
        {name: "arrow right", glyph: "", code: "f061", category: "arrows", aliases: "direction"},
        {name: "arrow down", glyph: "", code: "f063", category: "arrows", aliases: "direction"},
        {name: "arrow left", glyph: "", code: "f060", category: "arrows", aliases: "direction"},
        {name: "chevron up", glyph: "", code: "f077", category: "arrows", aliases: "caret"},
        {name: "chevron right", glyph: "", code: "f054", category: "arrows", aliases: "caret"},
        {name: "chevron down", glyph: "", code: "f078", category: "arrows", aliases: "caret"},
        {name: "chevron left", glyph: "", code: "f053", category: "arrows", aliases: "caret"}
    ]

    property var filteredGlyphs: {
        const query = root.searchText.trim().toLowerCase();
        if (query === "") {
            return root.glyphs;
        }

        let items = [];
        for (let i = 0; i < root.glyphs.length; i++) {
            const glyph = root.glyphs[i];
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

    function copyGlyph(glyph) {
        ClipboardService.copyToClipboard(glyph.glyph, false);
        utils.notify({
            summary: 'Copied: ' + glyph.name,
            body: glyph.glyph + '  U+' + glyph.code.toUpperCase()
        });
        root.requestExit();
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(() => searchField.forceActiveFocus());
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
            color: theme.text
            radius: Styles.radiusSm

            TextFieldStyled {
                id: searchField
                placeholderText: '/search nerdfont glyphs'
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                color: theme.background
                placeholderTextColor: theme.background
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

        TextStyled {
            Layout.fillWidth: true
            Layout.leftMargin: Styles.marginSm
            Layout.rightMargin: Styles.marginSm
            text: root.filteredGlyphs.length + ' glyphs • type to search by name, category, alias, or codepoint'
            color: theme.text
            font.pointSize: Styles.textSm
        }

        ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Styles.marginSm
            contentWidth: availableWidth

            GridLayoutPlus {
                id: glyphGrid
                focus: true
                columns: Math.max(1, Math.floor(parent.width / 180))
                anchors.left: parent.left
                anchors.right: parent.right
                rowSpacing: Styles.marginSm
                columnSpacing: Styles.marginSm

                Keys.onPressed: event => {
                    if (root.navigationHandler(event)) return;
                    if (controls.slashPressed(event)) {
                        searchField.forceActiveFocus();
                        event.accepted = true;
                        return;
                    }
                    if (controls.escapePressed(event)) {
                        root.requestExit();
                        event.accepted = true;
                        return;
                    }
                    if (controls.downPressed(event)) {
                        root.selectedIndex = Math.min(root.filteredGlyphs.length - 1, root.selectedIndex + glyphGrid.columns);
                        event.accepted = true;
                        return;
                    }
                    if (controls.upPressed(event)) {
                        root.selectedIndex = Math.max(0, root.selectedIndex - glyphGrid.columns);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Right) {
                        root.selectedIndex = Math.min(root.filteredGlyphs.length - 1, root.selectedIndex + 1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Left) {
                        root.selectedIndex = Math.max(0, root.selectedIndex - 1);
                        event.accepted = true;
                        return;
                    }
                    if (controls.enterPressed(event) && root.filteredGlyphs[root.selectedIndex]) {
                        root.copyGlyph(root.filteredGlyphs[root.selectedIndex]);
                        event.accepted = true;
                    }
                }

                model: root.filteredGlyphs
                delegate: ButtonStyled {
                    id: glyphButton

                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    radius: Styles.radiusMd
                    defaultColor: theme.foreground
                    isFocused: root.selectedIndex === glyphButton.index

                    onClicked: root.copyGlyph(glyphButton.modelData)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginXS

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
                            text: glyphButton.modelData.category + ' • U+' + glyphButton.modelData.code.toUpperCase()
                            color: theme.text
                            font.pointSize: Styles.textXs
                            opacity: 0.8
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
