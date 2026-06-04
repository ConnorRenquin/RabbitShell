pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Components
import qs.Settings
import qs.Services

Rectangle {
    id: root

    required property var view
    property var editorWindow: null

    function closeEditor() {
        if (root.editorWindow)
            root.editorWindow.exit();
        else
            root.visible = false;
    }

    visible: false
    Layout.fillHeight: true
    Layout.preferredWidth: 560
    color: Qt.lighter(Colors.surface, 1.2)

    readonly property var currentItem: root.view.selectedDeviceIndex >= 0
        ? root.view.deviceItems[root.view.selectedDeviceIndex]
        : null
    readonly property string selectedDeviceName: root.deviceVal("name")
    readonly property bool isDetectedDevice: root.selectedDeviceName.length > 0 && HyprctlDevices.allNames.indexOf(root.selectedDeviceName) !== -1
    readonly property bool isKeyboardDevice: HyprctlDevices.keyboardNames.indexOf(root.selectedDeviceName) !== -1
    readonly property bool isPointerDevice: HyprctlDevices.mouseNames.indexOf(root.selectedDeviceName) !== -1
    readonly property bool isTouchpadDevice: root.isPointerDevice && root.selectedDeviceName.toLowerCase().indexOf("touchpad") !== -1
    readonly property bool showPointerSettings: root.selectedDeviceName.length === 0 || !root.isDetectedDevice || root.isPointerDevice
    readonly property bool showKeyboardSettings: root.selectedDeviceName.length === 0 || !root.isDetectedDevice || root.isKeyboardDevice
    readonly property bool showTouchpadSettings: root.selectedDeviceName.length === 0 || !root.isDetectedDevice || root.isTouchpadDevice

    function deviceVal(key) {
        if (!root.currentItem)
            return "";
        let v = root.currentItem[key];
        return (v === undefined || v === null) ? "" : String(v);
    }

    function deviceBool(key) {
        if (!root.currentItem)
            return null;
        return root.currentItem[key];
    }

    function deviceNumber(key, fallbackValue) {
        let parsed = parseFloat(root.deviceVal(key));
        return isNaN(parsed) ? fallbackValue : parsed;
    }

    function boolComboIndex(key) {
        let val = root.deviceBool(key);
        if (val === null || val === undefined)
            return 0;
        return val ? 2 : 1;
    }

    function updateDevice(key, value) {
        root.view.updateDeviceItem(root.view.selectedDeviceIndex, key, value);
    }

    function setBoolFromCombo(key, index) {
        if (index === 0)
            root.updateDevice(key, null);
        else
            root.updateDevice(key, index === 2);
    }

    component SectionLabel: TextStyled {
        Layout.fillWidth: true
        font.bold: true
        font.pointSize: Styles.textSm
        opacity: 0.6
        topPadding: Styles.marginSm
    }

    component FieldLabel: TextStyled {
        Layout.preferredWidth: 180
    }

    component FieldInput: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        color: Qt.darker(Colors.background, Colors.darker)
        radius: Styles.radiusSm
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginMd
        spacing: Styles.marginSm

        RowLayout {
            Layout.fillWidth: true

            TextStyled {
                Layout.fillWidth: true
                text: "Edit Device Config"
                font.pointSize: Styles.textLg
            }

            ButtonStyled {
                text: Icons.close
                onClicked: root.closeEditor()
            }
        }

        ScrollView {
            id: editorScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: editorScroll.availableWidth
                spacing: Styles.marginXS

                // ─── Device Name ───────────────────────────────────────
                SectionLabel { text: "Device Name" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.marginXS

                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("name")
                            placeholderText: "elan0683:00-04f3:320b-touchpad"
                            onTextEdited: root.updateDevice("name", text)
                        }
                    }

                    ButtonStyled {
                        text: "󰑓"
                        onClicked: HyprctlDevices.refresh()
                    }
                }

                ComboBoxStyled {
                    visible: HyprctlDevices.allNames.length > 0
                    Layout.fillWidth: true
                    model: ["Select detected device..."].concat(HyprctlDevices.allNames)
                    currentIndex: {
                        let idx = HyprctlDevices.allNames.indexOf(root.deviceVal("name"));
                        return idx >= 0 ? idx + 1 : 0;
                    }
                    onActivated: index => {
                        if (index > 0)
                            root.updateDevice("name", HyprctlDevices.allNames[index - 1]);
                    }
                }

                // ─── Pointer / Mouse ──────────────────────────────────
                ColumnLayout {
                    visible: root.showPointerSettings
                    Layout.fillWidth: true
                    spacing: Styles.marginXS

                    SectionLabel { text: "Pointer / Mouse" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Styles.marginSm

                        FieldLabel { text: "Sensitivity" }

                        SliderSmallStyled {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            from: -1
                            to: 1
                            stepSize: 0.05
                            value: root.deviceNumber("sensitivity", 0)
                            showPercentage: false
                            onMoved: root.updateDevice("sensitivity", Number(value).toFixed(2))
                        }

                        TextStyled {
                            Layout.preferredWidth: 46
                            horizontalAlignment: Text.AlignRight
                            text: root.deviceVal("sensitivity") || "0.00"
                        }

                        ButtonStyled {
                            visible: root.deviceVal("sensitivity").length > 0
                            text: Icons.close
                            onClicked: root.updateDevice("sensitivity", "")
                        }
                    }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Accel Profile" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(default)", "flat", "adaptive", "custom"]
                        currentIndex: {
                            let v = root.deviceVal("accel_profile");
                            let idx = ["flat", "adaptive", "custom"].indexOf(v);
                            return idx >= 0 ? idx + 1 : 0;
                        }
                        onActivated: index => root.updateDevice("accel_profile", index === 0 ? "" : model[index])
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Force No Accel" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(unset)", "Off", "On"]
                        currentIndex: root.boolComboIndex("force_no_accel")
                        onActivated: index => root.setBoolFromCombo("force_no_accel", index)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Left Handed" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(unset)", "Off", "On"]
                        currentIndex: root.boolComboIndex("left_handed")
                        onActivated: index => root.setBoolFromCombo("left_handed", index)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Scroll Factor" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("scroll_factor")
                            placeholderText: "1.0"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            onTextEdited: root.updateDevice("scroll_factor", text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Scroll Method" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(default)", "no_scroll", "2fg", "edge", "on_button_down"]
                        currentIndex: {
                            let v = root.deviceVal("scroll_method");
                            let idx = ["no_scroll", "2fg", "edge", "on_button_down"].indexOf(v);
                            return idx >= 0 ? idx + 1 : 0;
                        }
                        onActivated: index => root.updateDevice("scroll_method", index === 0 ? "" : model[index])
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Natural Scroll" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(unset)", "Off", "On"]
                        currentIndex: root.boolComboIndex("natural_scroll")
                        onActivated: index => root.setBoolFromCombo("natural_scroll", index)
                    }
                }
                }

                // ─── Keyboard ─────────────────────────────────────────
                ColumnLayout {
                    visible: root.showKeyboardSettings
                    Layout.fillWidth: true
                    spacing: Styles.marginXS

                    SectionLabel { text: "Keyboard" }

                    RowLayout {
                        Layout.fillWidth: true
                        FieldLabel { text: "Layout" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("kb_layout")
                            placeholderText: "us"
                            onTextEdited: root.updateDevice("kb_layout", text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Variant" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("kb_variant")
                            placeholderText: "dvorak"
                            onTextEdited: root.updateDevice("kb_variant", text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Options" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("kb_options")
                            placeholderText: "caps:swapescape"
                            onTextEdited: root.updateDevice("kb_options", text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Model" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("kb_model")
                            placeholderText: ""
                            onTextEdited: root.updateDevice("kb_model", text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Rules" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("kb_rules")
                            placeholderText: ""
                            onTextEdited: root.updateDevice("kb_rules", text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "File" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("kb_file")
                            placeholderText: "/path/to/keymap.xkb"
                            onTextEdited: root.updateDevice("kb_file", text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Num Lock" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(unset)", "Off", "On"]
                        currentIndex: root.boolComboIndex("numlock_by_default")
                        onActivated: index => root.setBoolFromCombo("numlock_by_default", index)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Resolve By Sym" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(unset)", "Off", "On"]
                        currentIndex: root.boolComboIndex("resolve_binds_by_sym")
                        onActivated: index => root.setBoolFromCombo("resolve_binds_by_sym", index)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Repeat Rate" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("repeat_rate")
                            placeholderText: "25"
                            inputMethodHints: Qt.ImhDigitsOnly
                            onTextEdited: root.updateDevice("repeat_rate", text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Repeat Delay" }
                    FieldInput {
                        TextFieldStyled {
                            anchors.fill: parent
                            anchors.leftMargin: Styles.marginSm
                            anchors.rightMargin: Styles.marginSm
                            text: root.deviceVal("repeat_delay")
                            placeholderText: "600"
                            inputMethodHints: Qt.ImhDigitsOnly
                            onTextEdited: root.updateDevice("repeat_delay", text)
                        }
                    }
                }
                }

                // ─── Touchpad ─────────────────────────────────────────
                ColumnLayout {
                    visible: root.showTouchpadSettings
                    Layout.fillWidth: true
                    spacing: Styles.marginXS

                    SectionLabel { text: "Touchpad" }

                    RowLayout {
                        Layout.fillWidth: true
                        FieldLabel { text: "Disable While Typing" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(unset)", "Off", "On"]
                        currentIndex: root.boolComboIndex("disable_while_typing")
                        onActivated: index => root.setBoolFromCombo("disable_while_typing", index)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Middle Button Emulation" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(unset)", "Off", "On"]
                        currentIndex: root.boolComboIndex("middle_button_emulation")
                        onActivated: index => root.setBoolFromCombo("middle_button_emulation", index)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Drag Lock" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(unset)", "Off", "On"]
                        currentIndex: root.boolComboIndex("drag_lock")
                        onActivated: index => root.setBoolFromCombo("drag_lock", index)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Tap Button Map" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(default)", "lrm", "lmr"]
                        currentIndex: {
                            let v = root.deviceVal("tap_button_map");
                            let idx = ["lrm", "lmr"].indexOf(v);
                            return idx >= 0 ? idx + 1 : 0;
                        }
                        onActivated: index => root.updateDevice("tap_button_map", index === 0 ? "" : model[index])
                    }
                }
                }

                // ─── Other ─────────────────────────────────────────────
                SectionLabel { text: "Other" }

                RowLayout {
                    Layout.fillWidth: true
                    FieldLabel { text: "Transform" }
                    ComboBoxStyled {
                        Layout.fillWidth: true
                        model: ["(default)", "0", "90", "180", "270"]
                        currentIndex: {
                            let v = root.deviceVal("transform");
                            let idx = ["0", "90", "180", "270"].indexOf(v);
                            return idx >= 0 ? idx + 1 : 0;
                        }
                        onActivated: index => root.updateDevice("transform", index === 0 ? "" : model[index])
                    }
                }

                Item { Layout.preferredHeight: Styles.marginSm }
            }
        }

        ButtonStyled {
            text: Icons.trash
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            onClicked: root.view.removeDeviceItem(root.view.selectedDeviceIndex)
        }
    }
}
