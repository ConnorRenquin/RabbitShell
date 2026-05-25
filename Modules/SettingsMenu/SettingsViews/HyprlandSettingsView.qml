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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        SettingsViewTitle {
            title: "Hyprland"
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

                                        SettingsInputFrameLocal {
                                            visible: row.modelData.type !== "bool" && !row.modelData.options && !row.isColorRow && !(row.modelData.min !== undefined && row.modelData.max !== undefined)

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

                                visible: !!editorConfig
                                Layout.fillWidth: true
                                spacing: Styles.marginSm

                                ButtonStyled {
                                    text: listEditorColumn.editorConfig ? listEditorColumn.editorConfig.addText : ""
                                    Layout.fillWidth: true
                                    onClicked: root.addEditorItem(listEditorColumn.editorConfig)
                                }

                                Repeater {
                                    model: root.editorItems(listEditorColumn.editorConfig)

                                    delegate: CardLocal {
                                        id: editorItemRow
                                        required property var modelData
                                        required property int index
                                        readonly property var editorConfig: listEditorColumn.editorConfig

                                        Layout.preferredHeight: editorConfig ? editorConfig.cardHeight : 0

                                        CardColumnLocal {
                                            RowLayout {
                                                Layout.fillWidth: true

                                                TextStyled {
                                                    Layout.fillWidth: true
                                                    text: root.editorTitle(editorItemRow.editorConfig, editorItemRow.modelData)
                                                    font.bold: true
                                                }

                                                ButtonStyled {
                                                    text: Icons.trash
                                                    onClicked: root.removeEditorItem(editorItemRow.editorConfig, editorItemRow.index)
                                                }
                                            }

                                            Repeater {
                                                model: editorItemRow.editorConfig ? editorItemRow.editorConfig.rows : []

                                                delegate: ColumnLayout {
                                                    id: editorConfigRow
                                                    required property var modelData
                                                    readonly property bool isFlagsRow: modelData.type === "flags"

                                                    Layout.fillWidth: true
                                                    spacing: Styles.marginXS

                                                    RowLayout {
                                                        visible: !editorConfigRow.isFlagsRow
                                                        Layout.fillWidth: true
                                                        spacing: Styles.marginSm

                                                        Repeater {
                                                            model: editorConfigRow.modelData.fields || []

                                                            delegate: RowLayout {
                                                                id: editorField
                                                                required property var modelData
                                                                readonly property bool isBoolField: modelData.type === "bool"
                                                                readonly property bool isComboField: modelData.type === "combo"
                                                                readonly property bool isTextField: modelData.type === "text"

                                                                Layout.fillWidth: !isBoolField
                                                                spacing: Styles.marginSm

                                                                FormLabelLocal {
                                                                    visible: !editorField.isBoolField && !editorField.modelData.secondary
                                                                    text: editorField.modelData.label
                                                                }

                                                                SecondaryFormLabelLocal {
                                                                    visible: !editorField.isBoolField && !!editorField.modelData.secondary
                                                                    text: editorField.modelData.label
                                                                }

                                                                InputFrameLocal {
                                                                    visible: editorField.isTextField

                                                                    InputTextFieldLocal {
                                                                        text: root.fieldText(editorItemRow.modelData, editorField.modelData)
                                                                        placeholderText: editorField.modelData.placeholder || ""
                                                                        inputMethodHints: editorField.modelData.numeric ? Qt.ImhFormattedNumbersOnly : Qt.ImhNone
                                                                        onTextEdited: root.updateEditorItem(editorItemRow.editorConfig, editorItemRow.index, editorField.modelData.key, text)
                                                                    }
                                                                }

                                                                ComboBoxStyled {
                                                                    visible: editorField.isComboField
                                                                    Layout.fillWidth: true
                                                                    model: editorField.modelData.options || []
                                                                    currentIndex: root.comboFieldIndex(editorItemRow.modelData, editorField.modelData)
                                                                    onActivated: index => root.updateEditorItem(editorItemRow.editorConfig, editorItemRow.index, editorField.modelData.key, model[index])
                                                                }

                                                                SwitchStyled {
                                                                    visible: editorField.isBoolField
                                                                    text: editorField.modelData.label
                                                                    checked: root.boolFieldValue(editorItemRow.modelData, editorField.modelData)
                                                                    onToggled: root.updateEditorItem(editorItemRow.editorConfig, editorItemRow.index, editorField.modelData.key, checked)
                                                                }

                                                                ButtonStyled {
                                                                    visible: editorField.modelData.action === "captureBind"
                                                                    text: root.capturingBindIndex === editorItemRow.index ? "Press keys..." : "Detect"
                                                                    defaultColor: root.capturingBindIndex === editorItemRow.index ? Colors.primary : Colors.background
                                                                    onClicked: root.startCapturingBind(editorItemRow.index)
                                                                }
                                                            }
                                                        }
                                                    }

                                                    ColumnLayout {
                                                        visible: editorConfigRow.isFlagsRow
                                                        Layout.fillWidth: true
                                                        spacing: Styles.marginXS

                                                        TextStyled {
                                                            Layout.fillWidth: true
                                                            text: editorConfigRow.modelData.label || "Flags"
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
                                                                    checked: root.bindHasFlag(editorItemRow.modelData, modelData)
                                                                    onToggled: root.setBindFlag(editorItemRow.index, modelData, checked)
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
