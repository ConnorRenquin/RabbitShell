pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings

ColumnLayout {
    id: root

    property var headers: []
    property var model: []
    property int headerHeight: 34
    property int rowHeight: 42
    property int rowHorizontalMargin: Styles.marginSm
    property int rowSpacing: Styles.marginSm
    property int actionColumnWidth: 80
    property bool alternateRows: true
    property color headerColor: Qt.darker(Colors.background, Colors.darker)
    property color rowColor: Colors.surface
    property color alternateRowColor: Qt.darker(Colors.surface, 1.08)
    property Component row

    Layout.fillWidth: true
    spacing: 0

    function headerText(header) {
        if (typeof header === "string")
            return header;
        return header && header.title !== undefined ? header.title : "";
    }

    function isActionHeader(header) {
        return headerText(header).length === 0;
    }

    function applyColumnLayout(rowItem) {
        if (!rowItem || !rowItem.children)
            return;

        for (let i = 0; i < rowItem.children.length && i < headers.length; i++) {
            const child = rowItem.children[i];
            if (!child || !child.Layout)
                continue;

            const actionColumn = isActionHeader(headers[i]);
            child.Layout.fillWidth = !actionColumn;
            child.Layout.preferredWidth = actionColumn ? root.actionColumnWidth : 0;
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: root.headerHeight
        color: root.headerColor
        radius: Styles.radiusSm

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: root.rowHorizontalMargin
            anchors.rightMargin: root.rowHorizontalMargin
            spacing: root.rowSpacing

            Repeater {
                model: root.headers

                delegate: TextStyled {
                    required property var modelData

                    Layout.fillWidth: !root.isActionHeader(modelData)
                    Layout.preferredWidth: root.isActionHeader(modelData) ? root.actionColumnWidth : 0
                    horizontalAlignment: Qt.AlignLeft
                    text: root.headerText(modelData)
                    font.bold: true
                    elide: Text.ElideRight
                }
            }
        }
    }

    Repeater {
        model: root.model || []

        delegate: Rectangle {
            id: tableRowWrapper
            required property var modelData
            required property int index

            Layout.fillWidth: true
            Layout.preferredHeight: root.rowHeight
            color: root.alternateRows && index % 2 !== 0 ? root.alternateRowColor : root.rowColor
            radius: Styles.radiusSm

            Loader {
                id: rowLoader
                anchors.fill: parent
                anchors.leftMargin: root.rowHorizontalMargin
                anchors.rightMargin: root.rowHorizontalMargin
                sourceComponent: root.row

                onLoaded: {
                    item.modelData = tableRowWrapper.modelData;
                    item.index = tableRowWrapper.index;
                    if (item.spacing !== undefined)
                        item.spacing = root.rowSpacing;
                    root.applyColumnLayout(item);
                }
            }
        }
    }
}
