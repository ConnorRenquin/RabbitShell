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
    readonly property var bindItems: HyprlandSettings.bindItems
    readonly property var windowRuleItems: HyprlandSettings.windowRuleItems
    readonly property var layerRuleItems: HyprlandSettings.layerRuleItems
    readonly property var animationItems: HyprlandSettings.animationItems
    readonly property var bindFlagOptions: HyprlandSettings.bindFlagOptions
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
        bindEditorPopup.open();
    }

    function openListEditor(cfg, index) {
        selectedListEditorConfig = cfg;
        selectedListEditorIndex = index;
        listEditorPopup.open();
    }

    function selectedListItem() {
        var items = editorItems(selectedListEditorConfig);
        return selectedListEditorIndex >= 0 && selectedListEditorIndex < items.length ? items[selectedListEditorIndex] : null;
    }

    function listTableTitle(cfg, item) {
        return editorTitle(cfg, item);
    }

    function listTableColumnOne(cfg, item) {
        if (!cfg || !item)
            return "";
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

    Popup {
        id: bindEditorPopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: Math.min(root.width - Styles.marginLg * 2, 900)
        height: Math.min(root.height - Styles.marginLg * 2, 620)
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        padding: 0
        background: Rectangle {
            color: Colors.surface
            radius: Styles.radiusMd
            border.color: Colors.outline
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Styles.marginMd
            spacing: Styles.marginSm

            RowLayout {
                Layout.fillWidth: true

                TextStyled {
                    Layout.fillWidth: true
                    text: root.selectedBindIndex >= 0 ? "Edit keybind: " + root.bindName(root.bindItems[root.selectedBindIndex]) : "Edit keybind"
                    font.bold: true
                    font.pointSize: Styles.textLg
                }

                ButtonStyled {
                    text: "Close"
                    onClicked: bindEditorPopup.close()
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: Styles.marginMd
                rowSpacing: Styles.marginSm

                FormLabelLocal { text: "Name" }
                InputFrameLocal {
                    Layout.preferredHeight: 36
                    InputTextFieldLocal {
                        text: root.bindValue(root.selectedBindIndex, "description")
                        placeholderText: "Launch terminal"
                        onTextEdited: root.updateBindItem(root.selectedBindIndex, "description", text)
                    }
                }

                FormLabelLocal { text: "Keybind" }
                RowLayout {
                    Layout.fillWidth: true
                    InputFrameLocal {
                        Layout.preferredHeight: 36
                        InputTextFieldLocal {
                            text: root.bindValue(root.selectedBindIndex, "keys")
                            placeholderText: "SUPER + Return"
                            onTextEdited: root.updateBindItem(root.selectedBindIndex, "keys", text)
                        }
                    }
                    ButtonStyled {
                        text: root.capturingBindIndex === root.selectedBindIndex ? "Press keys..." : "Detect"
                        defaultColor: root.capturingBindIndex === root.selectedBindIndex ? Colors.primary : Colors.background
                        onClicked: root.startCapturingBind(root.selectedBindIndex)
                    }
                }

                FormLabelLocal { text: "Dispatcher" }
                ComboBoxStyled {
                    Layout.fillWidth: true
                    model: ["exec_cmd", "global", "raw", "callback"]
                    currentIndex: model.indexOf(root.bindValue(root.selectedBindIndex, "dispatcher"))
                    onActivated: index => root.updateBindItem(root.selectedBindIndex, "dispatcher", model[index])
                }

                FormLabelLocal { text: "Argument" }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: Qt.darker(Colors.background, Colors.darker)
                    radius: Styles.radiusSm

                    TextArea {
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        text: root.bindValue(root.selectedBindIndex, "argument")
                        placeholderText: "kitty, quickshell:powermenu, hl.dsp.focus(...), or function() ... end"
                        color: Colors.onBackground
                        selectedTextColor: Colors.background
                        selectionColor: Colors.primary
                        font.family: Styles.defaultFontFamily
                        font.pointSize: Styles.textSm
                        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                        selectByMouse: true
                        onTextChanged: {
                            if (root.selectedBindIndex >= 0 && text !== root.bindValue(root.selectedBindIndex, "argument"))
                                root.updateBindItem(root.selectedBindIndex, "argument", text);
                        }
                    }
                }
            }

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
                        required property string modelData
                        text: modelData
                        checked: root.bindHasFlag(root.bindItems[root.selectedBindIndex], modelData)
                        onToggled: root.setBindFlag(root.selectedBindIndex, modelData, checked)
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    Popup {
        id: listEditorPopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: Math.min(root.width - Styles.marginLg * 2, 860)
        height: Math.min(root.height - Styles.marginLg * 2, 560)
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        padding: 0
        background: Rectangle {
            color: Colors.surface
            radius: Styles.radiusMd
            border.color: Colors.outline
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Styles.marginMd
            spacing: Styles.marginSm

            RowLayout {
                Layout.fillWidth: true

                TextStyled {
                    Layout.fillWidth: true
                    text: root.selectedListEditorConfig ? "Edit " + root.editorTitle(root.selectedListEditorConfig, root.selectedListItem()) : "Edit rule"
                    font.bold: true
                    font.pointSize: Styles.textLg
                }

                ButtonStyled {
                    text: "Close"
                    onClicked: listEditorPopup.close()
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: Styles.marginSm

                    Repeater {
                        model: root.selectedListEditorConfig ? root.selectedListEditorConfig.rows : []

                        delegate: ColumnLayout {
                            id: popupEditorRow
                            required property var modelData

                            width: parent.width
                            spacing: Styles.marginXS

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Styles.marginSm

                                Repeater {
                                    model: popupEditorRow.modelData.fields || []

                                    delegate: RowLayout {
                                        id: popupEditorField
                                        required property var modelData
                                        readonly property bool isBoolField: modelData.type === "bool"
                                        readonly property bool isTextField: modelData.type === "text"

                                        Layout.fillWidth: !isBoolField
                                        spacing: Styles.marginSm

                                        FormLabelLocal {
                                            visible: !popupEditorField.isBoolField
                                            text: popupEditorField.modelData.label
                                        }

                                        InputFrameLocal {
                                            visible: popupEditorField.isTextField
                                            Layout.preferredHeight: 36

                                            InputTextFieldLocal {
                                                text: root.fieldText(root.selectedListItem(), popupEditorField.modelData)
                                                placeholderText: popupEditorField.modelData.placeholder || ""
                                                inputMethodHints: popupEditorField.modelData.numeric ? Qt.ImhFormattedNumbersOnly : Qt.ImhNone
                                                onTextEdited: root.updateEditorItem(root.selectedListEditorConfig, root.selectedListEditorIndex, popupEditorField.modelData.key, text)
                                            }
                                        }

                                        SwitchStyled {
                                            visible: popupEditorField.isBoolField
                                            text: popupEditorField.modelData.label
                                            checked: root.boolFieldValue(root.selectedListItem(), popupEditorField.modelData)
                                            onToggled: root.updateEditorItem(root.selectedListEditorConfig, root.selectedListEditorIndex, popupEditorField.modelData.key, checked)
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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        SettingsViewTitle {
            title: root.name
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
                    width: Math.max(tabText.implicitWidth + Styles.marginLg, 130)
                    text: ""
                    isFocused: root.currentGroupIndex === index

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

                                ColumnLayout {
                                    visible: listEditorColumn.isBindList
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 34
                                        color: Qt.darker(Colors.background, Colors.darker)
                                        radius: Styles.radiusSm

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: Styles.marginSm
                                            anchors.rightMargin: Styles.marginSm
                                            spacing: Styles.marginSm

                                            TextStyled { Layout.preferredWidth: 240; text: "Name"; font.bold: true }
                                            TextStyled { Layout.preferredWidth: 180; text: "Keybind"; font.bold: true }
                                            TextStyled { Layout.preferredWidth: 120; text: "Dispatch"; font.bold: true }
                                            TextStyled { Layout.fillWidth: true; text: "Arg"; font.bold: true }
                                            TextStyled { Layout.preferredWidth: 44; text: "" }
                                        }
                                    }

                                    Repeater {
                                        model: root.bindItems

                                        delegate: Rectangle {
                                            id: bindTableRow
                                            required property var modelData
                                            required property int index

                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 42
                                            color: index % 2 === 0 ? Colors.surface : Qt.darker(Colors.surface, 1.08)
                                            radius: Styles.radiusSm

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: Styles.marginSm
                                                anchors.rightMargin: Styles.marginSm
                                                spacing: Styles.marginSm

                                                TextStyled {
                                                    Layout.preferredWidth: 240
                                                    text: root.clippedText(root.bindName(bindTableRow.modelData), "Unnamed bind")
                                                    elide: Text.ElideRight
                                                    font.bold: true
                                                }

                                                TextStyled {
                                                    Layout.preferredWidth: 180
                                                    text: bindTableRow.modelData.keys || ""
                                                    elide: Text.ElideRight
                                                    color: Colors.primary
                                                }

                                                TextStyled {
                                                    Layout.preferredWidth: 120
                                                    text: bindTableRow.modelData.dispatcher || ""
                                                    elide: Text.ElideRight
                                                    opacity: 0.85
                                                }

                                                TextStyled {
                                                    Layout.fillWidth: true
                                                    text: root.clippedText(bindTableRow.modelData.argument, "")
                                                    elide: Text.ElideRight
                                                    opacity: 0.75
                                                }

                                                ButtonStyled {
                                                    Layout.preferredWidth: 36
                                                    text: "..."
                                                    onClicked: root.openBindEditor(bindTableRow.index)
                                                }

                                                ButtonStyled {
                                                    Layout.preferredWidth: 36
                                                    text: Icons.trash
                                                    onClicked: root.removeBindItem(bindTableRow.index)
                                                }
                                            }

                                        }
                                    }
                                }

                                ColumnLayout {
                                    visible: !!listEditorColumn.editorConfig && !listEditorColumn.isBindList
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 34
                                        color: Qt.darker(Colors.background, Colors.darker)
                                        radius: Styles.radiusSm

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: Styles.marginSm
                                            anchors.rightMargin: Styles.marginSm
                                            spacing: Styles.marginSm

                                            TextStyled { Layout.preferredWidth: 240; text: "Name"; font.bold: true }
                                            TextStyled { Layout.preferredWidth: 220; text: listEditorColumn.editorConfig && listEditorColumn.editorConfig.kind === "animationList" ? "State" : "Match"; font.bold: true }
                                            TextStyled { Layout.preferredWidth: 220; text: listEditorColumn.editorConfig && listEditorColumn.editorConfig.kind === "animationList" ? "Timing" : "Options"; font.bold: true }
                                            TextStyled { Layout.fillWidth: true; text: "Extra"; font.bold: true }
                                            TextStyled { Layout.preferredWidth: 80; text: "" }
                                        }
                                    }

                                    Repeater {
                                        model: root.editorItems(listEditorColumn.editorConfig)

                                        delegate: Rectangle {
                                            id: listTableRow
                                            required property var modelData
                                            required property int index
                                            readonly property var editorConfig: listEditorColumn.editorConfig

                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 42
                                            color: index % 2 === 0 ? Colors.surface : Qt.darker(Colors.surface, 1.08)
                                            radius: Styles.radiusSm

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: Styles.marginSm
                                                anchors.rightMargin: Styles.marginSm
                                                spacing: Styles.marginSm

                                                TextStyled {
                                                    Layout.preferredWidth: 240
                                                    text: root.clippedText(root.listTableTitle(listTableRow.editorConfig, listTableRow.modelData), "New rule")
                                                    elide: Text.ElideRight
                                                    font.bold: true
                                                }

                                                TextStyled {
                                                    Layout.preferredWidth: 220
                                                    text: root.clippedText(root.listTableColumnOne(listTableRow.editorConfig, listTableRow.modelData), "")
                                                    elide: Text.ElideRight
                                                    color: Colors.primary
                                                }

                                                TextStyled {
                                                    Layout.preferredWidth: 220
                                                    text: root.clippedText(root.listTableColumnTwo(listTableRow.editorConfig, listTableRow.modelData), "")
                                                    elide: Text.ElideRight
                                                    opacity: 0.85
                                                }

                                                TextStyled {
                                                    Layout.fillWidth: true
                                                    text: root.clippedText(root.listTableColumnThree(listTableRow.editorConfig, listTableRow.modelData), "")
                                                    elide: Text.ElideRight
                                                    opacity: 0.75
                                                }

                                                ButtonStyled {
                                                    Layout.preferredWidth: 36
                                                    text: "..."
                                                    onClicked: root.openListEditor(listTableRow.editorConfig, listTableRow.index)
                                                }

                                                ButtonStyled {
                                                    Layout.preferredWidth: 36
                                                    text: Icons.trash
                                                    onClicked: root.removeEditorItem(listTableRow.editorConfig, listTableRow.index)
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

        RowLayout {
            Layout.fillWidth: true
            spacing: Styles.marginSm

            Item {
                Layout.fillWidth: true
            }

            ButtonStyled {
                text: "Reload"
                onClicked: root.reloadConfig()
            }

            ButtonStyled {
                text: "Save"
                onClicked: root.saveConfig()
            }
        }
    }
}
