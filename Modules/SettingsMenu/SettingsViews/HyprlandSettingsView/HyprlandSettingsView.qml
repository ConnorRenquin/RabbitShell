pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCore as QtCoreLib

import qs.Components
import qs.Settings
import qs.Modules.SettingsMenu.SettingsViews.Components
import "./Components" as HyprlandViewComponents

import qs.Services

Rectangle {
    id: root

    required property string name

    color: Colors.surface
    focus: root.capturingBindIndex >= 0

    Keys.onPressed: event => {
        if (root.capturingBindIndex < 0)
            return;
        event.accepted = true;
        if (event.key === Qt.Key_Escape) {
            root.capturingBindIndex = -1;
            return;
        }
        var parts = [];
        if (event.modifiers & Qt.MetaModifier)
            parts.push("SUPER");
        if (event.modifiers & Qt.ControlModifier)
            parts.push("CTRL");
        if (event.modifiers & Qt.AltModifier)
            parts.push("ALT");
        if (event.modifiers & Qt.ShiftModifier)
            parts.push("SHIFT");
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
    property int selectedBindIndex: -1
    property int selectedListEditorIndex: -1
    property var selectedListEditorConfig: null
    property int pendingWindowRulePickIndex: -1
    readonly property var bindItems: HyprlandSettings.bindItems
    readonly property var windowRuleItems: HyprlandSettings.windowRuleItems
    readonly property var layerRuleItems: HyprlandSettings.layerRuleItems
    readonly property var animationItems: HyprlandSettings.animationItems
    readonly property var bindFlagOptions: HyprlandSettings.bindFlagOptions
    readonly property var commonBindActions: HyprlandSettings.commonBindActions
    readonly property var sections: HyprlandSettings.sections
    readonly property var sectionGroups: buildSectionGroups()
    property string pendingAggregateContent: ""
    property string statusText: ""

    component PanelLocal: Rectangle {
        Layout.fillWidth: true
        color: Colors.background
        radius: Styles.radiusSm
    }

    component CardLocal: Rectangle {
        Layout.fillWidth: true
        color: Colors.surface
        radius: Styles.radiusSm
    }

    component InputFrameLocal: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        color: Qt.darker(Colors.background, Colors.darker)
        radius: Styles.radiusSm
    }

    component SettingsInputFrameLocal: Rectangle {
        Layout.preferredWidth: 190
        Layout.fillHeight: true
        color: Qt.darker(Colors.surface, Colors.darker)
        radius: Styles.radiusSm
    }

    component InputTextFieldLocal: TextFieldStyled {
        anchors.fill: parent
        anchors.leftMargin: Styles.marginSm
        anchors.rightMargin: Styles.marginSm
    }

    component FormLabelLocal: TextStyled {
        Layout.preferredWidth: 90
    }

    component SecondaryFormLabelLocal: TextStyled {
        Layout.preferredWidth: 70
    }

    component CardColumnLocal: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm
    }

    function sectionGroup(section) {
        var title = section.title;
        if (["General", "Snap"].indexOf(title) !== -1)
            return "General";
        if (["Decoration", "Blur", "Shadow", "Glow", "Animations"].indexOf(title) !== -1)
            return "Appearance";
        if (["Input", "Touchpad", "Gestures", "Cursor"].indexOf(title) !== -1)
            return "Input";
        if (["Group", "Groupbar"].indexOf(title) !== -1)
            return "Windows";
        if (["Binds", "Keybind List"].indexOf(title) !== -1)
            return "Keybinds";
        if (["Window Rules", "Layer Rules", "Animation Rules"].indexOf(title) !== -1)
            return "Rules";
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
                group = {
                    title: groupName,
                    sections: []
                };
                groups.push(group);
            }
            group.sections.push(section);
        }
        return groups;
    }

    function getPath(path) {
        return HyprlandSettings.getPath(path);
    }
    function setPath(path, value) {
        HyprlandSettings.setPath(path, value);
    }
    function parseInput(text, type) {
        return HyprlandSettings.parseInput(text, type);
    }
    function displayValue(path) {
        return HyprlandSettings.displayValue(path);
    }
    function vector2Component(path, index) {
        return HyprlandSettings.vector2Component(path, index);
    }
    function setVector2Component(path, index, value) {
        HyprlandSettings.setVector2Component(path, index, value);
    }
    function isSettingVisible(setting) {
        return HyprlandSettings.isSettingVisible(setting);
    }
    function keyName(key, text) {
        return HyprlandSettings.keyName(key, text);
    }

    function addBindItem() {
        HyprlandSettings.addBindItem();
    }
    function removeBindItem(index) {
        HyprlandSettings.removeBindItem(index);
    }
    function updateBindItem(index, key, value) {
        HyprlandSettings.updateBindItem(index, key, value);
    }
    function bindHasFlag(bind, flag) {
        return HyprlandSettings.bindHasFlag(bind, flag);
    }
    function setBindFlag(index, flag, enabled) {
        HyprlandSettings.setBindFlag(index, flag, enabled);
    }
    function bindActionId(bind) {
        return HyprlandSettings.inferBindAction(bind);
    }
    function bindActionIndex(bind) {
        return HyprlandSettings.commonBindActionIndex(bindActionId(bind));
    }
    function bindAction(bind) {
        return HyprlandSettings.commonBindActionById(bindActionId(bind));
    }
    function bindParam(bind, key) {
        return HyprlandSettings.bindParam(bind, key);
    }
    function bindActionLabel(bind) {
        return bind && bind.advanced ? "Advanced" : bindAction(bind).label;
    }
    function bindActionSummary(bind) {
        if (!bind)
            return "";
        if (bind.advanced)
            return clippedText(bind.argument || "", "");
        var action = bindAction(bind);
        var parts = [];
        if (action.param)
            parts.push(bindParam(bind, action.param));
        if (action.secondaryParam)
            parts.push(bindParam(bind, action.secondaryParam));
        return parts.filter(x => String(x).length > 0).join(" · ");
    }
    function setBindAction(index, action) {
        HyprlandSettings.setBindAction(index, action);
    }
    function setBindAdvanced(index, advanced) {
        HyprlandSettings.setBindAdvanced(index, advanced);
    }
    function setBindParam(index, key, value) {
        HyprlandSettings.setBindParam(index, key, value);
    }
    function startCapturingBind(index) {
        capturingBindIndex = index;
        forceActiveFocus();
    }

    function editorItems(cfg) {
        var resultItems = [];
        if (!cfg) {
            return resultItems;
        }
        var editorKind = cfg.kind;

        if (editorKind === "bindList") {
            return HyprlandSettings.getBindItems();
        }
        if (editorKind === "windowRuleList") {
            return HyprlandSettings.getWindowRuleItems();
        }
        if (editorKind === "layerRuleList") {
            return HyprlandSettings.getLayerRuleItems();
        }
        if (editorKind === "animationList") {
            return HyprlandSettings.getAnimationItems();
        }
        return resultItems;
    }

    function addEditorItem(cfg) {
        if (!cfg)
            return;
        if (cfg.kind === "bindList")
            addBindItem();
        else if (cfg.kind === "windowRuleList")
            addWindowRuleItem();
        else if (cfg.kind === "layerRuleList")
            addLayerRuleItem();
        else if (cfg.kind === "animationList")
            addAnimationItem();
    }

    function removeEditorItem(cfg, index) {
        if (!cfg)
            return;
        if (cfg.kind === "bindList")
            removeBindItem(index);
        else if (cfg.kind === "windowRuleList")
            removeWindowRuleItem(index);
        else if (cfg.kind === "layerRuleList")
            removeLayerRuleItem(index);
        else if (cfg.kind === "animationList")
            removeAnimationItem(index);
    }

    function updateEditorItem(cfg, index, key, value) {
        if (!cfg)
            return;
        if (cfg.kind === "bindList")
            updateBindItem(index, key, value);
        else if (cfg.kind === "windowRuleList")
            updateWindowRuleItem(index, key, value);
        else if (cfg.kind === "layerRuleList")
            updateLayerRuleItem(index, key, value);
        else if (cfg.kind === "animationList")
            updateAnimationItem(index, key, value);
    }

    function editorTitle(cfg, item) {
        if (!cfg || !item)
            return "";
        var value = item[cfg.titleKey];
        return value !== undefined && String(value).length > 0 ? String(value) : cfg.titleFallback;
    }

    function bindName(item) {
        if (!item)
            return "";
        var value = item.description || item.name || item.comment || "";
        return String(value).trim().length > 0 ? String(value) : String(item.keys || "Unnamed bind");
    }

    function bindValue(index, key) {
        var item = bindItems[index];
        if (!item)
            return "";
        var value = item[key];
        return value === undefined || value === null ? "" : String(value);
    }

    function clippedText(value, fallback) {
        var text = String(value || fallback || "");
        return text.length > 80 ? text.slice(0, 77) + "..." : text;
    }

    function openBindEditor(index) {
        selectedBindIndex = index;
        listEditor.visible = false;
        bindEditor.visible = true;
    }

    function openListEditor(cfg, index) {
        selectedListEditorConfig = cfg;
        selectedListEditorIndex = index;
        bindEditor.visible = false;
        listEditor.visible = true;
    }

    function selectedListItem() {
        var items = editorItems(selectedListEditorConfig);
        return selectedListEditorIndex >= 0 && selectedListEditorIndex < items.length ? items[selectedListEditorIndex] : null;
    }

    function selectedListValue(key) {
        var item = selectedListItem();
        if (!item)
            return "";
        var value = item[key];
        return value === undefined || value === null ? "" : String(value);
    }

    function selectedListAdvanced() {
        var item = selectedListItem();
        return !!item && !!item.advanced;
    }

    function pickWindowForRule(index) {
        pendingWindowRulePickIndex = index;
        listEditor.visible = false;
        statusText = "Click/focus the target window now. Capturing active window in 2 seconds...";
        pickWindowProcess.running = true;
    }

    function applyPickedWindow(client) {
        if (pendingWindowRulePickIndex < 0 || !client)
            return;
        var windowClass = String(client.class || client.initialClass || "");
        var title = String(client.title || client.initialTitle || "");
        if (windowClass.length > 0)
            updateWindowRuleItem(pendingWindowRulePickIndex, "matchClass", windowClass);
        if (title.length > 0)
            updateWindowRuleItem(pendingWindowRulePickIndex, "matchTitle", title);
        if (windowClass.length > 0)
            updateWindowRuleItem(pendingWindowRulePickIndex, "name", "Rule for " + windowClass);
        statusText = windowClass.length > 0 ? "Captured window class " + windowClass : "Captured active window";
        pendingWindowRulePickIndex = -1;
    }

    function listTableTitle(cfg, item) {
        return editorTitle(cfg, item);
    }

    function listTableColumnOne(cfg, item) {
        if (!cfg || !item)
            return "";
        if (item.advanced)
            return "Advanced";
        if (cfg.kind === "windowRuleList")
            return (item.matchClass || "*") + (item.matchTitle ? " / " + item.matchTitle : "");
        if (cfg.kind === "layerRuleList")
            return item.namespace || "*";
        if (cfg.kind === "animationList")
            return item.enabled === false ? "Disabled" : "Enabled";
        return "";
    }

    function listTableColumnTwo(cfg, item) {
        if (!cfg || !item)
            return "";
        if (item.advanced)
            return root.clippedText(item.rawLine || "", "");
        if (cfg.kind === "windowRuleList") {
            var flags = [];
            if (item.float)
                flags.push("float");
            if (item.center)
                flags.push("center");
            if (item.opaque)
                flags.push("opaque");
            if (item.noBlur)
                flags.push("no blur");
            if (item.noShadow)
                flags.push("no shadow");
            return flags.join(", ");
        }
        if (cfg.kind === "layerRuleList") {
            var layerFlags = [];
            if (item.noAnim)
                layerFlags.push("no anim");
            if (item.blur)
                layerFlags.push("blur");
            if (item.xray)
                layerFlags.push("xray");
            if (item.ignoreAlpha)
                layerFlags.push("alpha " + item.ignoreAlpha);
            return layerFlags.join(", ");
        }
        if (cfg.kind === "animationList")
            return "speed " + (item.speed || "0") + (item.bezier ? " · " + item.bezier : "");
        return "";
    }

    function listTableColumnThree(cfg, item) {
        if (!cfg || !item)
            return "";
        if (item.advanced)
            return "";
        if (cfg.kind === "windowRuleList")
            return [item.size ? "size " + item.size : "", item.move ? "move " + item.move : "", item.rounding ? "round " + item.rounding : ""].filter(x => x.length > 0).join(" · ");
        if (cfg.kind === "animationList")
            return item.style || "";
        return "";
    }

    function fieldValue(item, field) {
        if (!item || !field)
            return "";
        var value = item[field.key];
        if (value === undefined || value === null)
            value = field.defaultValue !== undefined ? field.defaultValue : "";
        return field.stringify ? String(value || "") : value;
    }

    function fieldText(item, field) {
        var value = fieldValue(item, field);
        return value === undefined || value === null ? "" : String(value);
    }

    function boolFieldValue(item, field) {
        var value = fieldValue(item, field);
        return field.defaultValue !== undefined ? value !== false : !!value;
    }

    function comboFieldIndex(item, field) {
        var value = fieldValue(item, field);
        return field.options ? field.options.indexOf(value) : -1;
    }

    function addWindowRuleItem() {
        HyprlandSettings.addWindowRuleItem();
    }
    function removeWindowRuleItem(index) {
        HyprlandSettings.removeWindowRuleItem(index);
    }
    function updateWindowRuleItem(index, key, value) {
        HyprlandSettings.updateWindowRuleItem(index, key, value);
    }
    function addLayerRuleItem() {
        HyprlandSettings.addLayerRuleItem();
    }
    function removeLayerRuleItem(index) {
        HyprlandSettings.removeLayerRuleItem(index);
    }
    function updateLayerRuleItem(index, key, value) {
        HyprlandSettings.updateLayerRuleItem(index, key, value);
    }
    function addAnimationItem() {
        HyprlandSettings.addAnimationItem();
    }
    function removeAnimationItem(index) {
        HyprlandSettings.removeAnimationItem(index);
    }
    function updateAnimationItem(index, key, value) {
        HyprlandSettings.updateAnimationItem(index, key, value);
    }

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

    Process {
        id: pickWindowProcess
        command: ["bash", "-c", "sleep 2; hyprctl activewindow -j"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var client = JSON.parse(text);
                    root.applyPickedWindow(client);
                } catch (e) {
                    root.statusText = "Failed to parse active window details";
                    root.pendingWindowRulePickIndex = -1;
                }
            }
        }

        function onExited(exitCode) {
            if (exitCode !== 0) {
                root.statusText = "Failed to capture active window (exit code " + exitCode + ")";
                root.pendingWindowRulePickIndex = -1;
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



    RowLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm
        ColumnLayout {
            id: content
            Layout.fillWidth: true
            Layout.fillHeight: true

            SettingsViewTitle {
                title: root.name
            }

            Rectangle {
                id: saveButtons
                Layout.preferredHeight: 50
                radius: Styles.radiusSm
                Layout.fillWidth: true
                z: 2
                color: Colors.surface
                RowLayout {
                    id: saveLoadRow
                    spacing: Styles.marginXS
                    anchors.fill: parent
                    ButtonStyled {
                        text: "Reload"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: root.reloadConfig()
                    }
                    ButtonStyled {
                        text: "Save"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: root.saveConfig()
                    }
                }
            }

            PanelLocal {
                id: sectionTabs
                Layout.preferredHeight: 44

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
                        text: groupTabButton.modelData.title
                        isFocused: root.currentGroupIndex === index

                        onClicked: {
                            root.currentGroupIndex = index;
                            sectionTabsList.positionViewAtIndex(index, ListView.Contain);
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

                        delegate: PanelLocal {
                            id: sectionDelegate
                            required property var modelData

                            implicitHeight: sectionColumn.implicitHeight + Styles.marginMd

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
                                        readonly property bool isColorRow: modelData.type === "raw" && modelData.path.indexOf(".color") >= 0

                                        visible: root.isSettingVisible(row.modelData)
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: visible ? (row.isColorRow || (row.modelData.min !== undefined && row.modelData.max !== undefined) ? 54 : 38) : 0
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

                                            ColorComboBoxStyled {
                                                id: colorCombo
                                                visible: row.isColorRow
                                                Layout.preferredWidth: 190
                                                Layout.fillHeight: true
                                                selectedHyprColorValue: visible ? root.getPath(row.modelData.path) : ""
                                                onActivated: index => root.setPath(row.modelData.path, colorCombo.hyprColorValueWithOpacity(colorCombo.colorNames[index], opacitySlider.value))
                                            }

                                            SliderSmallStyled {
                                                id: opacitySlider
                                                visible: row.isColorRow
                                                Layout.preferredWidth: 190
                                                Layout.fillHeight: true
                                                from: 0
                                                to: 1
                                                stepSize: 0.05
                                                value: visible ? colorCombo.opacityFromHyprValue(root.getPath(row.modelData.path)) : 1
                                                showPercentage: true
                                                onMoved: root.setPath(row.modelData.path, colorCombo.hyprColorValueWithOpacity(colorCombo.selectedColorName, value))
                                            }

                                            SliderSmallStyled {
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

                                            RowLayout {
                                                visible: row.modelData.type === "vector2"
                                                Layout.preferredWidth: 190
                                                Layout.fillHeight: true
                                                spacing: Styles.marginSm

                                                SettingsInputFrameLocal {
                                                    Layout.preferredWidth: 85
                                                    InputTextFieldLocal {
                                                        text: visible ? String(root.vector2Component(row.modelData.path, 0)) : ""
                                                        placeholderText: "X"
                                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                        onTextEdited: root.setVector2Component(row.modelData.path, 0, text)
                                                    }
                                                }

                                                SettingsInputFrameLocal {
                                                    Layout.preferredWidth: 85
                                                    InputTextFieldLocal {
                                                        text: visible ? String(root.vector2Component(row.modelData.path, 1)) : ""
                                                        placeholderText: "Y"
                                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                        onTextEdited: root.setVector2Component(row.modelData.path, 1, text)
                                                    }
                                                }
                                            }

                                            SettingsInputFrameLocal {
                                                visible: row.modelData.type !== "bool" && row.modelData.type !== "vector2" && !row.modelData.options && !row.isColorRow && !(row.modelData.min !== undefined && row.modelData.max !== undefined)

                                                InputTextFieldLocal {
                                                    property string valueText: parent.visible ? root.displayValue(row.modelData.path) : ""
                                                    Component.onCompleted: text = valueText
                                                    onValueTextChanged: {
                                                        if (!activeFocus && text !== valueText)
                                                            text = valueText;
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
                                    id: listEditorColumn
                                    property var editorConfig: sectionDelegate.modelData.editor || null
                                    readonly property bool isBindList: !!editorConfig && editorConfig.kind === "bindList"

                                    visible: !!editorConfig
                                    Layout.fillWidth: true
                                    spacing: Styles.marginSm

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Styles.marginSm

                                        ButtonStyled {
                                            text: listEditorColumn.editorConfig ? listEditorColumn.editorConfig.addText : ""
                                            Layout.preferredWidth: 160
                                            onClicked: root.addEditorItem(listEditorColumn.editorConfig)
                                        }

                                        TextStyled {
                                            visible: listEditorColumn.isBindList
                                            Layout.fillWidth: true
                                            text: root.bindItems.length + " keybinds"
                                            opacity: 0.7
                                        }
                                    }

                                    Table {
                                        visible: listEditorColumn.isBindList
                                        headers: ["Name", "Keybind", ""]
                                        model: root.bindItems
                                        rowHeight: 50
                                        alternateRows: false
                                        rowColor: Qt.darker(Colors.surface, 1.08)
                                        row: RowLayout {
                                            id: bindTableRow
                                            property var modelData
                                            property int index

                                            anchors.fill: parent

                                            TextStyled {
                                                Layout.fillWidth: true
                                                text: root.clippedText(root.bindName(bindTableRow.modelData), "Unnamed bind")
                                                elide: Text.ElideRight
                                            }
                                            TextStyled {
                                                Layout.fillWidth: true
                                                text: bindTableRow.modelData.keys || ""
                                                elide: Text.ElideRight
                                            }
                                            ButtonStyled {
                                                text: Icons.settingsCog
                                                onClicked: root.openBindEditor(bindTableRow.index)
                                            }
                                        }
                                    }

                                    Table {
                                        visible: !!listEditorColumn.editorConfig && !listEditorColumn.isBindList
                                        headers: ["Name", listEditorColumn.editorConfig && listEditorColumn.editorConfig.kind === "animationList" ? "State" : "Match", listEditorColumn.editorConfig && listEditorColumn.editorConfig.kind === "animationList" ? "Timing" : "Options", "Extra", ""]
                                        model: root.editorItems(listEditorColumn.editorConfig)
                                        row: RowLayout {
                                            id: ruleTableRow
                                            property var modelData
                                            property int index

                                            readonly property var editorConfig: listEditorColumn.editorConfig

                                            anchors.fill: parent

                                            TextStyled {
                                                text: root.clippedText(root.listTableTitle(ruleTableRow.editorConfig, ruleTableRow.modelData), "New rule")
                                                elide: Text.ElideRight
                                            }
                                            TextStyled {
                                                text: root.clippedText(root.listTableColumnOne(ruleTableRow.editorConfig, ruleTableRow.modelData), "")
                                                elide: Text.ElideRight
                                            }
                                            TextStyled {
                                                text: root.clippedText(root.listTableColumnTwo(ruleTableRow.editorConfig, ruleTableRow.modelData), "")
                                                elide: Text.ElideRight
                                            }
                                            TextStyled {
                                                text: root.clippedText(root.listTableColumnThree(ruleTableRow.editorConfig, ruleTableRow.modelData), "")
                                                elide: Text.ElideRight
                                            }
                                            RowLayout {

                                                ButtonStyled {
                                                    text: Icons.settingsCog
                                                    onClicked: root.openListEditor(ruleTableRow.editorConfig, ruleTableRow.index)
                                                }

                                                ButtonStyled {
                                                    text: Icons.trash
                                                    onClicked: root.removeEditorItem(ruleTableRow.editorConfig, ruleTableRow.index)
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

        HyprlandViewComponents.HyprlandListEditor {
            id: listEditor
            view: root
        }

        HyprlandViewComponents.HyprlandBindEditor {
            id: bindEditor
            view: root
        }
    }
}
