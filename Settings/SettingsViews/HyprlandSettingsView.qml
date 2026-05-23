pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCore as QtCoreLib

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root

    color: Colors.surface
    focus: root.capturingBindIndex >= 0

    Keys.onPressed: event => {
        if (root.capturingBindIndex < 0) return;
        event.accepted = true;
        if (event.key === Qt.Key_Escape) {
            root.capturingBindIndex = -1;
            return;
        }
        var parts = [];
        if (event.modifiers & Qt.MetaModifier) parts.push("SUPER");
        if (event.modifiers & Qt.ControlModifier) parts.push("CTRL");
        if (event.modifiers & Qt.AltModifier) parts.push("ALT");
        if (event.modifiers & Qt.ShiftModifier) parts.push("SHIFT");
        var key = root.keyName(event.key, event.text);
        var captured = key.length > 0 ? parts.concat([key]).join(" + ") : "";
        if (captured.length > 0) {
            root.updateBindItem(root.capturingBindIndex, "keys", captured);
            root.capturingBindIndex = -1;
        }
    }




    readonly property string configDir: HyprlandSettings.configDir
    readonly property string configPath: HyprlandSettings.configPath
    readonly property string configUrl: HyprlandSettings.configUrl
    readonly property var values: HyprlandSettings.values
    property bool loading: true
    property bool needsInitialSave: false
    property int currentGroupIndex: 0
    property int capturingBindIndex: -1
    readonly property var bindItems: HyprlandSettings.bindItems
    readonly property var windowRuleItems: HyprlandSettings.windowRuleItems
    readonly property var layerRuleItems: HyprlandSettings.layerRuleItems
    readonly property var animationItems: HyprlandSettings.animationItems
    readonly property var bindFlagOptions: HyprlandSettings.bindFlagOptions
    readonly property var sections: HyprlandSettings.sections
    readonly property var sectionGroups: buildSectionGroups()
    property string pendingAggregateContent: ""
    property string statusText: ""

    function sectionGroup(section) {
        var title = section.title;
        if (["General", "Snap", "Misc"].indexOf(title) !== -1)
            return "General";
        if (["Decoration", "Blur", "Shadow", "Glow"].indexOf(title) !== -1)
            return "Appearance";
        if (["Input", "Touchpad", "Gestures"].indexOf(title) !== -1)
            return "Input";
        if (["Group", "Groupbar"].indexOf(title) !== -1)
            return "Windows";
        if (["Binds", "Keybind List"].indexOf(title) !== -1)
            return "Keybinds";
        if (["Window Rules", "Layer Rules", "Animation Rules"].indexOf(title) !== -1)
            return "Rules";
        if (["Animations", "XWayland", "OpenGL / Render", "Cursor"].indexOf(title) !== -1)
            return "Rendering";
        return "Advanced";
    }

    function buildSectionGroups() {
        var groups = [];
        for (var i = 0; i < HyprlandSettings.sections.length; i++) {
            var section = HyprlandSettings.sections[i];
            var groupName = sectionGroup(section);
            var group = null;
            for (var g = 0; g < groups.length; g++) {
                if (groups[g].title === groupName) {
                    group = groups[g];
                    break;
                }
            }
            if (!group) {
                group = { title: groupName, sections: [] };
                groups.push(group);
            }
            group.sections.push(section);
        }
        return groups;
    }

    function getPath(path) { return HyprlandSettings.getPath(path); }
    function setPath(path, value) { HyprlandSettings.setPath(path, value); }
    function parseInput(text, type) { return HyprlandSettings.parseInput(text, type); }
    function displayValue(path) { return HyprlandSettings.displayValue(path); }
    function isSettingVisible(setting) { return HyprlandSettings.isSettingVisible(setting); }
    function keyName(key, text) { return HyprlandSettings.keyName(key, text); }

    function addBindItem() { HyprlandSettings.addBindItem(); }
    function removeBindItem(index) { HyprlandSettings.removeBindItem(index); }
    function updateBindItem(index, key, value) { HyprlandSettings.updateBindItem(index, key, value); }
    function bindHasFlag(bind, flag) { return HyprlandSettings.bindHasFlag(bind, flag); }
    function setBindFlag(index, flag, enabled) { HyprlandSettings.setBindFlag(index, flag, enabled); }
    function startCapturingBind(index) {
        capturingBindIndex = index;
        forceActiveFocus();
    }

    function addWindowRuleItem() { HyprlandSettings.addWindowRuleItem(); }
    function removeWindowRuleItem(index) { HyprlandSettings.removeWindowRuleItem(index); }
    function updateWindowRuleItem(index, key, value) { HyprlandSettings.updateWindowRuleItem(index, key, value); }
    function addLayerRuleItem() { HyprlandSettings.addLayerRuleItem(); }
    function removeLayerRuleItem(index) { HyprlandSettings.removeLayerRuleItem(index); }
    function updateLayerRuleItem(index, key, value) { HyprlandSettings.updateLayerRuleItem(index, key, value); }
    function addAnimationItem() { HyprlandSettings.addAnimationItem(); }
    function removeAnimationItem(index) { HyprlandSettings.removeAnimationItem(index); }
    function updateAnimationItem(index, key, value) { HyprlandSettings.updateAnimationItem(index, key, value); }

    function writeFileCommand(path, content, marker) {
        return "cat > \"" + path + "\" <<'" + marker + "'\n" + content + marker + "\n";
    }

    function saveConfig() {
        var aggregateContent = HyprlandSettings.generateConfig();
        pendingAggregateContent = aggregateContent;
        var cmd = "mkdir -p \"" + configDir + "\"\n";
        cmd += writeFileCommand(configPath, aggregateContent, "QSAGGEOF");
        for (var i = 0; i < sections.length; i++) {
            var section = sections[i];
            cmd += writeFileCommand(HyprlandSettings.sectionFilePath(section), HyprlandSettings.generateSectionConfig(section), "QSSECTION" + i + "EOF");
        }
        writeConfig.command = ["bash", "-c", cmd];
        writeConfig.running = true;
        statusText = "Saving per-tab Hyprland files to " + configDir;
    }

    function reloadConfig() {
        var text = pendingAggregateContent.length > 0 ? pendingAggregateContent : configFile.text();
        HyprlandSettings.loadFromText(text);
        statusText = "Loaded " + configPath;
    }
    Component.onCompleted: {
        ensureDirectory.running = true;
    }

    Process {
        id: ensureDirectory
        command: ["mkdir", "-p", root.configDir]
        running: false
        function onExited(exitCode) {
            if (exitCode !== 0) {
                root.statusText = "Failed to create " + root.configDir;
                return;
            }
            if (root.needsInitialSave) {
                root.needsInitialSave = false;
                root.saveConfig();
            }
        }
    }

    Process {
        id: writeConfig
        running: false
        function onExited(exitCode) {
            if (exitCode === 0) {
                if (root.pendingAggregateContent.length > 0) {
                    configFile.setText(root.pendingAggregateContent);
                }
                root.statusText = "Saved per-tab Hyprland files to " + root.configDir;
            } else {
                root.statusText = "Failed to save Hyprland files in " + root.configDir + " (exit code " + exitCode + ")";
            }
        }
    }

    FileView {
        id: configFile
        path: root.configUrl
        blockLoading: false

        onLoaded: {
            root.loading = false;
            root.reloadConfig();
        }

        onLoadFailed: {
            root.loading = false;
            HyprlandSettings.values = HyprlandSettings.clone(HyprlandSettings.defaultValues);
            root.needsInitialSave = true;
            ensureDirectory.running = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        RowLayout {
            Layout.fillWidth: true
            spacing: Styles.marginSm

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                TextStyled {
                    text: "Hyprland Decorations"
                    font.pointSize: Styles.textLg
                    font.bold: true
                }

                TextStyled {
                    Layout.fillWidth: true
                    text: "Writes a Lua config fragment to ~/.config/hypr/quickshell/decorations.lua for manual insertion."
                    wrapMode: Text.WordWrap
                    opacity: 0.8
                }
            }

            ButtonStyled {
                text: "Reload"
                onClicked: root.reloadConfig()
            }

            ButtonStyled {
                text: "Save"
                defaultColor: Colors.primary
                onClicked: root.saveConfig()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: statusLabel.implicitHeight + Styles.marginSm
            color: Colors.background
            radius: Styles.radiusSm

            TextStyled {
                id: statusLabel
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                text: root.statusText || "Edit values, then Save. Generated file is not inserted into your main Hyprland config automatically."
                wrapMode: Text.WordWrap
                opacity: 0.8
                font.pointSize: Styles.textSm
            }
        }

        Rectangle {
            id: sectionTabs
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: Colors.background
            radius: Styles.radiusSm

            ListView {
                id: sectionTabsList
                anchors.fill: parent
                anchors.margins: Styles.marginXS
                orientation: ListView.Horizontal
                spacing: Styles.marginSm
                clip: true
                model: root.sectionGroups

                delegate: ButtonStyled {
                    id: groupTabButton
                    required property var modelData
                    required property int index

                    height: sectionTabsList.height
                    width: Math.max(tabText.implicitWidth + Styles.marginLg, 130)
                    text: ""
                    isFocused: root.currentGroupIndex === index
                    defaultColor: root.currentGroupIndex === index ? Colors.primary : Colors.surface

                    onClicked: {
                        root.currentGroupIndex = index;
                        sectionTabsList.positionViewAtIndex(index, ListView.Contain);
                    }

                    TextStyled {
                        id: tabText
                        anchors.centerIn: parent
                        text: groupTabButton.modelData.title
                        font.bold: root.currentGroupIndex === groupTabButton.index
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: Styles.marginMd

                Repeater {
                    model: root.sectionGroups.length > 0 ? root.sectionGroups[root.currentGroupIndex].sections : []

                    delegate: Rectangle {
                        id: sectionDelegate
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: sectionColumn.implicitHeight + Styles.marginMd
                        color: Colors.background
                        radius: Styles.radiusSm

                        ColumnLayout {
                            id: sectionColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: Styles.marginSm
                            spacing: Styles.marginSm

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Styles.marginSm

                                TextStyled {
                                    Layout.fillWidth: true
                                    text: sectionDelegate.modelData.title
                                    font.pointSize: Styles.textLg
                                    font.bold: true
                                }

                                ButtonStyled {
                                    text: Icons.info + " Wiki"
                                    visible: !!sectionDelegate.modelData.wiki
                                    onClicked: Quickshell.execDetached(["xdg-open", sectionDelegate.modelData.wiki])
                                }
                            }

                            TextStyled {
                                Layout.fillWidth: true
                                text: sectionDelegate.modelData.subtitle
                                wrapMode: Text.WordWrap
                                opacity: 0.75
                                font.pointSize: Styles.textSm
                            }

                            Repeater {
                                model: sectionDelegate.modelData.settings

                                delegate: Rectangle {
                                    id: row
                                    required property var modelData

                                    visible: root.isSettingVisible(row.modelData)
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: visible ? (row.modelData.min !== undefined && row.modelData.max !== undefined ? 54 : 38) : 0
                                    color: "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: Styles.marginMd

                                        TextStyled {
                                            Layout.fillWidth: true
                                            text: row.modelData.label
                                        }

                                        SwitchStyled {
                                            visible: row.modelData.type === "bool"
                                            checked: visible ? !!root.getPath(row.modelData.path) : false
                                            onToggled: root.setPath(row.modelData.path, checked)
                                        }

                                        ComboBoxStyled {
                                            visible: !!row.modelData.options
                                            Layout.preferredWidth: 190
                                            Layout.fillHeight: true
                                            model: visible ? row.modelData.options : []
                                            currentIndex: visible ? (row.modelData.optionValues ? row.modelData.optionValues.indexOf(root.getPath(row.modelData.path)) : row.modelData.options.indexOf(root.getPath(row.modelData.path))) : -1
                                            onActivated: index => root.setPath(row.modelData.path, row.modelData.optionValues ? row.modelData.optionValues[index] : row.modelData.options[index])
                                        }

                                        SliderStyled {
                                            visible: row.modelData.min !== undefined && row.modelData.max !== undefined
                                            Layout.preferredWidth: 220
                                            Layout.fillHeight: true
                                            from: visible ? row.modelData.min : 0
                                            to: visible ? row.modelData.max : 1
                                            stepSize: visible ? (row.modelData.step || (row.modelData.type === "int" ? 1 : 0.05)) : 0.05
                                            value: visible ? root.getPath(row.modelData.path) : from
                                            showPercentage: false
                                            onMoved: root.setPath(row.modelData.path, row.modelData.type === "int" ? Math.round(value) : value)
                                        }

                                        TextStyled {
                                            visible: row.modelData.min !== undefined && row.modelData.max !== undefined
                                            Layout.preferredWidth: 52
                                            horizontalAlignment: Text.AlignRight
                                            text: visible ? Number(root.getPath(row.modelData.path)).toFixed(row.modelData.type === "int" ? 0 : 2) : ""
                                        }

                                        Rectangle {
                                            visible: row.modelData.type !== "bool" && !row.modelData.options && !(row.modelData.min !== undefined && row.modelData.max !== undefined)
                                            Layout.preferredWidth: 190
                                            Layout.fillHeight: true
                                            color: Qt.darker(Colors.surface, Colors.darker)
                                            radius: Styles.radiusSm

                                            TextFieldStyled {
                                                anchors.fill: parent
                                                anchors.leftMargin: Styles.marginSm
                                                anchors.rightMargin: Styles.marginSm
                                                property string valueText: parent.visible ? root.displayValue(row.modelData.path) : ""
                                                Component.onCompleted: text = valueText
                                                onValueTextChanged: {
                                                    if (!activeFocus && text !== valueText) text = valueText;
                                                }
                                                placeholderText: row.modelData.label
                                                inputMethodHints: row.modelData.type === "string" || row.modelData.type === "raw" ? Qt.ImhNone : Qt.ImhFormattedNumbersOnly
                                                onTextEdited: root.setPath(row.modelData.path, root.parseInput(text, row.modelData.type))
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: sectionDelegate.modelData.kind === "bindList"
                                Layout.fillWidth: true
                                spacing: Styles.marginSm

                                ButtonStyled {
                                    text: "+ Add keybind"
                                    Layout.fillWidth: true
                                    onClicked: root.addBindItem()
                                }

                                Repeater {
                                    model: root.bindItems

                                    delegate: Rectangle {
                                        id: bindRow
                                        required property var modelData
                                        required property int index

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 250
                                        color: Colors.surface
                                        radius: Styles.radiusSm

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: Styles.marginSm
                                            spacing: Styles.marginSm

                                            RowLayout {
                                                Layout.fillWidth: true
                                                TextStyled { Layout.fillWidth: true; text: bindRow.modelData.keys || "New keybind"; font.bold: true }
                                                ButtonStyled { text: Icons.trash; onClicked: root.removeBindItem(bindRow.index) }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                TextStyled { Layout.preferredWidth: 90; text: "Keys" }
                                                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm
                                                    TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: bindRow.modelData.keys || ""; placeholderText: "SUPER + Return"; onTextEdited: root.updateBindItem(bindRow.index, "keys", text) }
                                                }
                                                ButtonStyled {
                                                    text: root.capturingBindIndex === bindRow.index ? "Press keys..." : "Detect"
                                                    defaultColor: root.capturingBindIndex === bindRow.index ? Colors.primary : Colors.background
                                                    onClicked: root.startCapturingBind(bindRow.index)
                                                }
                                            }
                                            RowLayout {
                                                Layout.fillWidth: true
                                                TextStyled { Layout.preferredWidth: 90; text: "Dispatcher" }
                                                ComboBoxStyled { Layout.fillWidth: true; model: ["exec", "global"]; currentIndex: model.indexOf(bindRow.modelData.dispatcher || "exec"); onActivated: index => root.updateBindItem(bindRow.index, "dispatcher", model[index]) }
                                            }
                                            RowLayout {
                                                Layout.fillWidth: true
                                                TextStyled { Layout.preferredWidth: 90; text: "Argument" }
                                                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm
                                                    TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: bindRow.modelData.argument || ""; placeholderText: "kitty or quickshell:powermenu"; onTextEdited: root.updateBindItem(bindRow.index, "argument", text) }
                                                }
                                            }
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: Styles.marginXS

                                                TextStyled {
                                                    Layout.fillWidth: true
                                                    text: "Flags"
                                                    font.bold: true
                                                }

                                                Flow {
                                                    Layout.fillWidth: true
                                                    spacing: Styles.marginSm

                                                    Repeater {
                                                        model: root.bindFlagOptions

                                                        delegate: SwitchStyled {
                                                            id: flagSwitch
                                                            required property string modelData
                                                            text: modelData
                                                            checked: root.bindHasFlag(bindRow.modelData, modelData)
                                                            onToggled: root.setBindFlag(bindRow.index, modelData, checked)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: sectionDelegate.modelData.kind === "windowRuleList"
                                Layout.fillWidth: true
                                spacing: Styles.marginSm

                                ButtonStyled { text: "+ Add window rule"; Layout.fillWidth: true; onClicked: root.addWindowRuleItem() }

                                Repeater {
                                    model: root.windowRuleItems
                                    delegate: Rectangle {
                                        id: ruleRow
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 230
                                        color: Colors.surface
                                        radius: Styles.radiusSm
                                        ColumnLayout {
                                            anchors.fill: parent; anchors.margins: Styles.marginSm; spacing: Styles.marginSm
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.fillWidth: true; text: ruleRow.modelData.name || "New window rule"; font.bold: true } ButtonStyled { text: Icons.trash; onClicked: root.removeWindowRuleItem(ruleRow.index) } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Name" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: ruleRow.modelData.name || ""; placeholderText: "Rule name"; onTextEdited: root.updateWindowRuleItem(ruleRow.index, "name", text) } } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Class" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: ruleRow.modelData.matchClass || ""; placeholderText: "firefox|kitty"; onTextEdited: root.updateWindowRuleItem(ruleRow.index, "matchClass", text) } } TextStyled { Layout.preferredWidth: 70; text: "Title" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: ruleRow.modelData.matchTitle || ""; placeholderText: "Settings"; onTextEdited: root.updateWindowRuleItem(ruleRow.index, "matchTitle", text) } } }
                                            RowLayout { Layout.fillWidth: true; SwitchStyled { text: "Float"; checked: !!ruleRow.modelData.float; onToggled: root.updateWindowRuleItem(ruleRow.index, "float", checked) } SwitchStyled { text: "Center"; checked: !!ruleRow.modelData.center; onToggled: root.updateWindowRuleItem(ruleRow.index, "center", checked) } SwitchStyled { text: "Opaque"; checked: !!ruleRow.modelData.opaque; onToggled: root.updateWindowRuleItem(ruleRow.index, "opaque", checked) } SwitchStyled { text: "No blur"; checked: !!ruleRow.modelData.noBlur; onToggled: root.updateWindowRuleItem(ruleRow.index, "noBlur", checked) } SwitchStyled { text: "No shadow"; checked: !!ruleRow.modelData.noShadow; onToggled: root.updateWindowRuleItem(ruleRow.index, "noShadow", checked) } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Size" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: ruleRow.modelData.size || ""; placeholderText: "500, monitor_h*0.5"; onTextEdited: root.updateWindowRuleItem(ruleRow.index, "size", text) } } TextStyled { Layout.preferredWidth: 70; text: "Move" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: ruleRow.modelData.move || ""; placeholderText: "cursor_x, cursor_y"; onTextEdited: root.updateWindowRuleItem(ruleRow.index, "move", text) } } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Rounding" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: ruleRow.modelData.rounding || ""; placeholderText: "10"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextEdited: root.updateWindowRuleItem(ruleRow.index, "rounding", text) } } }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: sectionDelegate.modelData.kind === "layerRuleList"
                                Layout.fillWidth: true
                                spacing: Styles.marginSm
                                ButtonStyled { text: "+ Add layer rule"; Layout.fillWidth: true; onClicked: root.addLayerRuleItem() }
                                Repeater {
                                    model: root.layerRuleItems
                                    delegate: Rectangle {
                                        id: layerRow
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 165
                                        color: Colors.surface
                                        radius: Styles.radiusSm
                                        ColumnLayout {
                                            anchors.fill: parent; anchors.margins: Styles.marginSm; spacing: Styles.marginSm
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.fillWidth: true; text: layerRow.modelData.name || "New layer rule"; font.bold: true } ButtonStyled { text: Icons.trash; onClicked: root.removeLayerRuleItem(layerRow.index) } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Name" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: layerRow.modelData.name || ""; placeholderText: "Rule name"; onTextEdited: root.updateLayerRuleItem(layerRow.index, "name", text) } } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Namespace" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: layerRow.modelData.namespace || ""; placeholderText: "notifications|toplevels"; onTextEdited: root.updateLayerRuleItem(layerRow.index, "namespace", text) } } }
                                            RowLayout { Layout.fillWidth: true; SwitchStyled { text: "No anim"; checked: !!layerRow.modelData.noAnim; onToggled: root.updateLayerRuleItem(layerRow.index, "noAnim", checked) } SwitchStyled { text: "Blur"; checked: !!layerRow.modelData.blur; onToggled: root.updateLayerRuleItem(layerRow.index, "blur", checked) } SwitchStyled { text: "Xray"; checked: !!layerRow.modelData.xray; onToggled: root.updateLayerRuleItem(layerRow.index, "xray", checked) } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Ignore alpha" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: layerRow.modelData.ignoreAlpha || ""; placeholderText: "0.2"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextEdited: root.updateLayerRuleItem(layerRow.index, "ignoreAlpha", text) } } }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: sectionDelegate.modelData.kind === "animationList"
                                Layout.fillWidth: true
                                spacing: Styles.marginSm
                                ButtonStyled { text: "+ Add animation"; Layout.fillWidth: true; onClicked: root.addAnimationItem() }
                                Repeater {
                                    model: root.animationItems
                                    delegate: Rectangle {
                                        id: animRow
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 165
                                        color: Colors.surface
                                        radius: Styles.radiusSm
                                        ColumnLayout {
                                            anchors.fill: parent; anchors.margins: Styles.marginSm; spacing: Styles.marginSm
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.fillWidth: true; text: animRow.modelData.leaf || "New animation"; font.bold: true } ButtonStyled { text: Icons.trash; onClicked: root.removeAnimationItem(animRow.index) } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Leaf" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: animRow.modelData.leaf || ""; placeholderText: "windowsIn"; onTextEdited: root.updateAnimationItem(animRow.index, "leaf", text) } } SwitchStyled { text: "Enabled"; checked: animRow.modelData.enabled !== false; onToggled: root.updateAnimationItem(animRow.index, "enabled", checked) } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Speed" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: String(animRow.modelData.speed || ""); placeholderText: "4"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextEdited: root.updateAnimationItem(animRow.index, "speed", text) } } }
                                            RowLayout { Layout.fillWidth: true; TextStyled { Layout.preferredWidth: 90; text: "Bezier" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: animRow.modelData.bezier || ""; placeholderText: "default"; onTextEdited: root.updateAnimationItem(animRow.index, "bezier", text) } } TextStyled { Layout.preferredWidth: 70; text: "Style" } Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Qt.darker(Colors.background, Colors.darker); radius: Styles.radiusSm; TextFieldStyled { anchors.fill: parent; anchors.leftMargin: Styles.marginSm; text: animRow.modelData.style || ""; placeholderText: "popin"; onTextEdited: root.updateAnimationItem(animRow.index, "style", text) } } }
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
