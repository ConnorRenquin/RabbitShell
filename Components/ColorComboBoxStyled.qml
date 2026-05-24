pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import qs.Components
import qs.Settings

ComboBoxStyled {
    id: root

    property var colorNames: [
        "primary", "onPrimary",
        "primaryContainer", "onPrimaryContainer",
        "inversePrimary",
        "secondary", "onSecondary",
        "secondaryContainer", "onSecondaryContainer",
        "tertiary", "onTertiary",
        "tertiaryContainer", "onTertiaryContainer",
        "error", "onError",
        "surface", "onSurface",
        "surfaceVariant", "onSurfaceVariant",
        "outline", "outlineVariant",
        "background", "onBackground",
        "shadow", "scrim"
    ]
    property string selectedColorName: currentText
    property string selectedHyprColorValue: ""
    readonly property color selectedColor: colorValue(selectedColorName)
    property int colorSampleSize: 16
    property int colorSampleRadius: 4

    model: colorNames

    function colorValue(colorName) {
        return Colors[colorName] ?? "transparent";
    }

    function alphaHex(opacity) {
        const alpha = Math.max(0, Math.min(255, Math.round(opacity * 255)));
        return alpha.toString(16).padStart(2, "0");
    }

    function rgbHex(colorName) {
        const colorText = String(root.colorValue(colorName)).trim();
        if (colorText[0] !== "#") {
            return colorText;
        }

        const hex = colorText.slice(1);
        if (hex.length === 6) {
            return hex;
        }
        if (hex.length === 8) {
            return hex.slice(2);
        }
        return colorText;
    }

    function hyprColorValue(colorName) {
        return root.hyprColorValueWithOpacity(colorName, 1);
    }

    function hyprColorValueWithOpacity(colorName, opacity) {
        const rgb = root.rgbHex(colorName);
        if (rgb.length !== 6) {
            return rgb;
        }
        return "0x" + root.alphaHex(opacity) + rgb;
    }

    function opacityFromHyprValue(hyprValue) {
        const valueText = String(hyprValue || "").trim().toLowerCase();
        if (valueText.indexOf("0x") === 0 && valueText.length >= 10) {
            const alpha = parseInt(valueText.slice(2, 4), 16);
            return isNaN(alpha) ? 1 : alpha / 255;
        }
        if (valueText[0] === "#" && valueText.length === 9) {
            const hashAlpha = parseInt(valueText.slice(1, 3), 16);
            return isNaN(hashAlpha) ? 1 : hashAlpha / 255;
        }
        return 1;
    }

    function colorNameFromHyprValue(hyprValue) {
        const valueText = String(hyprValue || "").trim().toLowerCase();
        if (valueText.length === 0) {
            return "";
        }

        let rgb = valueText;
        if (rgb.indexOf("0x") === 0 && rgb.length >= 10) {
            rgb = rgb.slice(4, 10);
        } else if (rgb[0] === "#") {
            rgb = rgb.length === 9 ? rgb.slice(3, 9) : rgb.slice(1, 7);
        }

        for (let i = 0; i < root.colorNames.length; i++) {
            const colorName = root.colorNames[i];
            if (root.rgbHex(colorName).toLowerCase() === rgb) {
                return colorName;
            }
        }

        return "";
    }

    function selectColor(colorName) {
        const index = root.colorNames.indexOf(colorName);
        if (index >= 0) {
            root.currentIndex = index;
            root.selectedColorName = colorName;
        }
    }

    onActivated: index => {
        root.selectedColorName = root.colorNames[index] ?? "";
    }

    onSelectedColorNameChanged: {
        if (root.currentText !== root.selectedColorName) {
            root.selectColor(root.selectedColorName);
        }
    }

    onSelectedHyprColorValueChanged: {
        const colorName = root.colorNameFromHyprValue(root.selectedHyprColorValue);
        if (colorName.length > 0 && colorName !== root.selectedColorName) {
            root.selectedColorName = colorName;
        }
    }

    contentItem: Item {
        implicitHeight: selectedRow.implicitHeight

        Row {
            id: selectedRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: Styles.marginSm
            rightPadding: root.indicator.width + Styles.marginSm
            spacing: Styles.marginSm

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: root.colorSampleSize
                implicitHeight: root.colorSampleSize
                radius: root.colorSampleRadius
                color: root.selectedColor
                border.width: 1
                border.color: Colors.outline
            }

            TextStyled {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - root.colorSampleSize - parent.spacing - parent.leftPadding - parent.rightPadding
                text: root.selectedColorName
                elide: Text.ElideRight
            }
        }
    }

    delegate: ItemDelegate {
        id: colorDelegate

        required property int index
        required property string modelData

        width: root.width
        height: root.delegateHeight
        highlighted: root.highlightedIndex === colorDelegate.index

        contentItem: Row {
            spacing: Styles.marginSm
            leftPadding: Styles.marginSm
            rightPadding: Styles.marginSm

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: root.colorSampleSize
                implicitHeight: root.colorSampleSize
                radius: root.colorSampleRadius
                color: root.colorValue(colorDelegate.modelData)
                border.width: 1
                border.color: Colors.outline
            }

            TextStyled {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - root.colorSampleSize - parent.spacing - parent.leftPadding - parent.rightPadding
                text: colorDelegate.modelData
                elide: Text.ElideRight
            }
        }

        background: Rectangle {
            color: colorDelegate.highlighted ? Colors.onSurface : "transparent"
            radius: Styles.radiusSm

            ColorAnimation on color {
                duration: 50
            }
        }
    }
}
