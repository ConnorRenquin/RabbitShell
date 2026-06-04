pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCore as QtCoreLib

import qs.Components
import qs.Components.Plus
import qs.Components.Styled
import qs.Settings
import qs.Modules.SettingsMenu.SettingsViews.Components
import "./Components" as HyprlandViewComponents

import qs.Services

FloatingWindowPlus {
    id: window

    color: Colors.surface
    title: 'Hyprland Settings'
    persistId: "hyprland-settings"

    Component.onCompleted: PatchBay.openHyprlandSettings.connect(toggle)

    delegate: Rectangle {
        id: root

        anchors.fill: parent
        color: Colors.surface
        focus: root.capturingBindIndex >= 0

        property string name: Icons.hyprland + ' Hyprland'

    Keys.onPressed: event => {
        if (root.capturingBindIndex < 0)
            return;
        event.accepted = true;
        if (event.key === Qt.Key_Escape) {
            root.capturingBindIndex = -1;
            return;
        }
        let parts = [];
        if (event.modifiers & Qt.MetaModifier)
            parts.push("SUPER");
        if (event.modifiers & Qt.ControlModifier)
            parts.push("CTRL");
        if (event.modifiers & Qt.AltModifier)
            parts.push("ALT");
        if (event.modifiers & Qt.ShiftModifier)
            parts.push("SHIFT");
        let key = root.keyName(event.key, event.text);
        let captured = key.length > 0 ? parts.concat([key]).join(" + ") : "";
        if (captured.length > 0) {
            root.updateBindItem(root.capturingBindIndex, "keys", captured);
            root.capturingBindIndex = -1;
        }
    }

    readonly property string configDir: HyprlandSettings.configDir
    readonly property string configPath: HyprlandSettings.configPath
    readonly property string configUrl: HyprlandSettings.configUrl
    property bool loading: true
    property bool needsInitialSave: false
    property int currentGroupIndex: 0
    property int capturingBindIndex: -1
    property int selectedBindIndex: -1
    property int selectedListEditorIndex: -1
    property var selectedListEditorConfig: null
    property int pendingWindowRulePickIndex: -1
    readonly property list<var> bindItems: HyprlandSettings.bindItems
    readonly property list<var> windowRuleItems: HyprlandSettings.windowRuleItems
    readonly property list<var> layerRuleItems: HyprlandSettings.layerRuleItems
    readonly property list<var> animationItems: HyprlandSettings.animationItems
    readonly property list<var> deviceItems: HyprlandSettings.deviceItems
    property int selectedDeviceIndex: -1
    readonly property list<string> bindFlagOptions: HyprlandSettings.bindFlagOptions
    readonly property list<var> commonBindActions: HyprlandSettings.commonBindActions
    readonly property list<var> sections: HyprlandSettings.sections
    readonly property list<var> sectionGroups: buildSectionGroups()
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
        let title = section.title;
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
        if (["Device Config"].indexOf(title) !== -1)
            return "Devices";
        return "Advanced";
    }

    function buildSectionGroups() {
        let groups = [];
        for (let i = 0; i < HyprlandSettings.sections.length; i++) {
            let section = HyprlandSettings.sections[i];
            let groupName = sectionGroup(section);
            let group = null;
            for (let g = 0; g < groups.length; g++) {
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
        let action = bindAction(bind);
        let parts = [];
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
        let resultItems = [];
        if (!cfg) {
            return resultItems;
        }
        let editorKind = cfg.kind;

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
        if (editorKind === "deviceList") {
            return HyprlandSettings.getDeviceItems();
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
        else if (cfg.kind === "deviceList")
            addDeviceItem();
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
        else if (cfg.kind === "deviceList")
            removeDeviceItem(index);
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
        else if (cfg.kind === "deviceList")
            updateDeviceItem(index, key, value);
    }

    function editorTitle(cfg, item) {
        if (!cfg || !item)
            return "";
        let value = item[cfg.titleKey];
        return value !== undefined && String(value).length > 0 ? String(value) : cfg.titleFallback;
    }

    function bindName(item) {
        if (!item)
            return "";
        let value = item.description || item.name || item.comment || "";
        return String(value).trim().length > 0 ? String(value) : String(item.keys || "Unnamed bind");
    }

    function bindValue(index, key) {
        let item = bindItems[index];
        if (!item)
            return "";
        let value = item[key];
        return value === undefined || value === null ? "" : String(value);
    }

    function clippedText(value, fallback) {
        let text = String(value || fallback || "");
        return text.length > 80 ? text.slice(0, 77) + "..." : text;
    }

    function openBindEditor(index) {
        selectedBindIndex = index;
        listEditorWindow.exit();
        deviceEditorWindow.exit();
        bindEditorWindow.open();
    }

    function openListEditor(cfg, index) {
        selectedListEditorConfig = cfg;
        selectedListEditorIndex = index;
        bindEditorWindow.exit();
        deviceEditorWindow.exit();
        listEditorWindow.open();
    }

    function selectedListItem() {
        let items = editorItems(selectedListEditorConfig);
        return selectedListEditorIndex >= 0 && selectedListEditorIndex < items.length ? items[selectedListEditorIndex] : null;
    }

    function selectedListValue(key) {
        let item = selectedListItem();
        if (!item)
            return "";
        let value = item[key];
        return value === undefined || value === null ? "" : String(value);
    }

    function selectedListAdvanced() {
        let item = selectedListItem();
        return !!item && !!item.advanced;
    }

    function pickWindowForRule(index) {
        pendingWindowRulePickIndex = index;
        statusText = "Click/focus the target window now. Capturing active window in 2 seconds...";
        pickWindowProcess.running = true;
    }

    function applyPickedWindow(client) {
        if (pendingWindowRulePickIndex < 0 || !client)
            return;
        let windowClass = String(client.class || client.initialClass || "");
        let title = String(client.title || client.initialTitle || "");
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
        if (cfg && cfg.kind === "deviceList" && item)
            return item.name || "New device";
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
        if (cfg.kind === "deviceList") {
            let parts = [];
            if (String(item.sensitivity || "").trim())
                parts.push("sens " + item.sensitivity);
            if (item.accel_profile)
                parts.push(item.accel_profile);
            return parts.join(" \u00b7 ") || "\u2014";
        }
        return "";
    }

    function listTableColumnTwo(cfg, item) {
        if (!cfg || !item)
            return "";
        if (item.advanced)
            return root.clippedText(item.rawLine || "", "");
        if (cfg.kind === "windowRuleList") {
            let flags = [];
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
            let layerFlags = [];
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
            return "speed " + (item.speed || "0") + (item.bezier ? " \u00b7 " + item.bezier : "");
        if (cfg.kind === "deviceList") {
            let parts = [];
            if (item.kb_layout)
                parts.push("layout: " + item.kb_layout);
            if (item.natural_scroll === true)
                parts.push("natural scroll");
            if (item.disable_while_typing === false)
                parts.push("dwt off");
            return parts.join(" \u00b7 ") || "\u2014";
        }
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
        let value = item[field.key];
        if (value === undefined || value === null)
            value = field.defaultValue !== undefined ? field.defaultValue : "";
        return field.stringify ? String(value || "") : value;
    }

    function fieldText(item, field) {
        let value = fieldValue(item, field);
        return value === undefined || value === null ? "" : String(value);
    }

    function boolFieldValue(item, field) {
        let value = fieldValue(item, field);
        return field.defaultValue !== undefined ? value !== false : !!value;
    }

    function comboFieldIndex(item, field) {
        let value = fieldValue(item, field);
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
    function addDeviceItem() {
        HyprlandSettings.addDeviceItem();
    }
    function removeDeviceItem(index) {
        HyprlandSettings.removeDeviceItem(index);
        if (root.selectedDeviceIndex === index)
            root.selectedDeviceIndex = -1;
    }
    function updateDeviceItem(index, key, value) {
        HyprlandSettings.updateDeviceItem(index, key, value);
    }
    function selectedDeviceItem() {
        return root.selectedDeviceIndex >= 0 && root.selectedDeviceIndex < root.deviceItems.length
            ? root.deviceItems[root.selectedDeviceIndex]
            : null;
    }
    function openDeviceEditor(index) {
        root.selectedDeviceIndex = index;
        listEditorWindow.exit();
        bindEditorWindow.exit();
        deviceEditorWindow.open();
    }

    function writeFileCommand(path, content, marker) {
        return "cat > \"" + path + "\" <<'" + marker + "'\n" + content + marker + "\n";
    }

    function saveConfig() {
        let aggregateContent = HyprlandSettings.generateConfig();
        pendingAggregateContent = aggregateContent;
        let cmd = "mkdir -p \"" + configDir + "\"\n";
        cmd += writeFileCommand(configPath, aggregateContent, "QSAGGEOF");
        for (let i = 0; i < sections.length; i++) {
            let section = sections[i];
            cmd += writeFileCommand(HyprlandSettings.sectionFilePath(section), HyprlandSettings.generateSectionConfig(section), "QSSECTION" + i + "EOF");
        }
        writeConfig.command = ["bash", "-c", cmd];
        writeConfig.running = true;
        statusText = "Saving per-tab Hyprland files to " + configDir;
    }

    function reloadConfig() {
        let text = pendingAggregateContent.length > 0 ? pendingAggregateContent : configFile.text();
        HyprlandSettings.loadFromText(text);
        statusText = "Loaded " + configPath;
    }

    function ensureSectionFiles() {
        let cmd = "mkdir -p \"" + configDir + "\"\n";
        for (let i = 0; i < sections.length; i++) {
            let section = sections[i];
            let path = HyprlandSettings.sectionFilePath(section);
            cmd += "if [ ! -f \"" + path + "\" ]; then\n";
            cmd += writeFileCommand(path, HyprlandSettings.generateSectionConfig(section), "QSMISSINGSECTION" + i + "EOF");
            cmd += "fi\n";
        }
        ensureSectionFilesProcess.command = ["bash", "-c", cmd];
        ensureSectionFilesProcess.running = true;
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
        id: ensureSectionFilesProcess
        running: false
        function onExited(exitCode) {
            if (exitCode !== 0)
                root.statusText = "Failed to create missing Hyprland section files (exit code " + exitCode + ")";
        }
    }

    Process {
        id: pickWindowProcess
        command: ["bash", "-c", "sleep 2; hyprctl activewindow -j"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let client = JSON.parse(text);
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
            root.ensureSectionFiles();
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
                                        headers: {
                                            let cfg = listEditorColumn.editorConfig;
                                            if (cfg && cfg.kind === "deviceList")
                                                return ["Device", "Pointer", "Keyboard", ""];
                                            return ["Name", cfg && cfg.kind === "animationList" ? "State" : "Match", cfg && cfg.kind === "animationList" ? "Timing" : "Options", "Extra", ""];
                                        }
                                        model: root.editorItems(listEditorColumn.editorConfig)
                                        row: RowLayout {
                                            id: ruleTableRow
                                            property var modelData
                                            property int index

                                            readonly property var editorConfig: listEditorColumn.editorConfig
                                            readonly property bool isDeviceList: !!editorConfig && editorConfig.kind === "deviceList"

                                            anchors.fill: parent

                                            TextStyled {
                                                text: root.clippedText(root.listTableTitle(ruleTableRow.editorConfig, ruleTableRow.modelData), ruleTableRow.isDeviceList ? "New device" : "New rule")
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
                                                visible: !ruleTableRow.isDeviceList
                                                text: root.clippedText(root.listTableColumnThree(ruleTableRow.editorConfig, ruleTableRow.modelData), "")
                                                elide: Text.ElideRight
                                            }
                                            ButtonStyled {
                                                text: Icons.settingsCog
                                                onClicked: {
                                                    if (ruleTableRow.isDeviceList)
                                                        root.openDeviceEditor(ruleTableRow.index);
                                                    else
                                                        root.openListEditor(ruleTableRow.editorConfig, ruleTableRow.index);
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

    component FloatingWindowLocal:  FloatingWindow {
        title: "Settings Menu Popup"
        visible: false
        color: Qt.lighter(Colors.surface, 1.2)
        minimumSize: Qt.size(550, 520)

        function open() {
            visible = true;
        }

        function exit() {
            visible = false;
        }

        onClosed: exit()
    }


    FloatingWindowLocal {
        id: listEditorWindow
        HyprlandViewComponents.HyprlandListEditor {
            view: root
            editorWindow: listEditorWindow
            visible: true
            anchors.fill: parent
        }
    }

    FloatingWindowLocal {
        id: bindEditorWindow
        HyprlandViewComponents.HyprlandBindEditor {
            view: root
            editorWindow: bindEditorWindow
            visible: true
            anchors.fill: parent
        }
    }

    FloatingWindowLocal {
        id: deviceEditorWindow
        HyprlandViewComponents.HyprlandDeviceEditor {
            view: root
            editorWindow: deviceEditorWindow
            visible: true
            anchors.fill: parent
        }
    }
    }
}
