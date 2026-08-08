pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.Components.Plus
import qs.Components.Styled
import qs.Helpers
import qs.Settings

Item {
    id: root

    required property var setting
    property string stagedWidget: ""

    implicitHeight: content.implicitHeight

    readonly property var widgets: setting.editorOptions?.widgets ?? []
    readonly property var sections: setting.editorOptions?.sections ?? []

    Themer {
        id: theme
        settingName: "barWidgetsEditorColor"
    }

    function changeValue(value) {
        Settings.change({ name: setting.name, value: value });
    }

    function entriesFor(section) {
        const entries = [];
        for (let index = 0; index < setting.value.length; index++) {
            if (setting.value[index].section === section)
                entries.push({ entry: setting.value[index], sourceIndex: index });
        }
        return entries;
    }

    function moveWidget(sourceIndex, widget, section, targetPosition) {
        const entries = setting.value.slice();
        let movedEntry = { widget: widget, section: section };

        if (sourceIndex >= 0) {
            movedEntry = Object.assign({}, entries[sourceIndex], { section: section });
            entries.splice(sourceIndex, 1);
        }

        const sectionIndices = [];
        for (let index = 0; index < entries.length; index++) {
            if (entries[index].section === section)
                sectionIndices.push(index);
        }

        const insertAt = targetPosition < sectionIndices.length
            ? sectionIndices[targetPosition]
            : (sectionIndices.length > 0 ? sectionIndices[sectionIndices.length - 1] + 1 : entries.length);
        entries.splice(insertAt, 0, movedEntry);
        changeValue(entries);

        if (sourceIndex < 0)
            stagedWidget = "";
    }

    function droppedSourceIndex(drop) {
        const source = drop.source;
        return source.sourceIndex;
    }

    function droppedWidget(drop) {
        const source = drop.source;
        return source.widget;
    }

    function removeEntry(sourceIndex) {
        const entries = setting.value.slice();
        entries.splice(sourceIndex, 1);
        changeValue(entries);
    }

    ColumnLayout {
        id: content
        width: parent.width
        spacing: Styles.marginSm

        TextStyled {
            Layout.fillWidth: true
            color: theme.text
            text: Settings.toDisplayName(root.setting.name)
        }

        ScrollViewPlus {
            id: sectionScroll
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            contentWidth: availableWidth

            RowLayout {
                width: sectionScroll.availableWidth
                spacing: Styles.marginSm

            Repeater {
                model: root.sections

                delegate: Rectangle {
                    id: sectionBox

                    required property string modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    implicitHeight: sectionContent.implicitHeight + Styles.marginSm * 2
                    radius: Styles.radiusSm
                    color: theme.background

                    readonly property var sectionEntries: root.entriesFor(modelData)

                    ColumnLayout {
                        id: sectionContent
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: Styles.marginSm
                        }
                        spacing: Styles.marginSm

                        TextStyled {
                            Layout.fillWidth: true
                            color: theme.text
                            text: Settings.toDisplayName(sectionBox.modelData)
                        }

                        Repeater {
                            model: sectionBox.sectionEntries

                            delegate: DragCard {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                widget: modelData.entry.widget
                                sourceIndex: modelData.sourceIndex
                                targetSection: sectionBox.modelData
                                targetPosition: index
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: Styles.radiusSm
                            color: appendDrop.containsDrag ? theme.foreground : "transparent"

                            TextStyled {
                                anchors.centerIn: parent
                                color: theme.text
                                text: sectionBox.sectionEntries.length === 0 ? "Drop here" : "Drop to append"
                            }

                            DropArea {
                                id: appendDrop
                                anchors.fill: parent
                                keys: ["barWidget"]
                                onDropped: drop => {
                                    root.moveWidget(root.droppedSourceIndex(drop), root.droppedWidget(drop),
                                        sectionBox.modelData, sectionBox.sectionEntries.length);
                                    drop.acceptProposedAction();
                                }
                            }
                        }
                    }
                }
            }
        }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.stagedWidget ? 48 : 32
            radius: Styles.radiusSm
            color: theme.background

            TextStyled {
                anchors.centerIn: parent
                visible: !root.stagedWidget
                color: theme.text
                text: "Spawn a widget, then drag it into a section"
            }

            DragCard {
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                visible: !!root.stagedWidget
                widget: root.stagedWidget
                sourceIndex: -1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            spacing: Styles.marginSm

            ComboBoxStyled {
                id: widgetPicker
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.widgets
                currentIndex: 0
            }

            ButtonStyled {
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                text: "Spawn"
                textColor: theme.text
                defaultColor: theme.foreground
                enabled: root.widgets.length > 0
                onClicked: root.stagedWidget = root.widgets[widgetPicker.currentIndex]
            }
        }
    }

    component DragCard: Rectangle {
        id: card

        required property string widget
        required property int sourceIndex
        property string targetSection: ""
        property int targetPosition: -1
        property real dragStartX: 0
        property real dragStartY: 0

        implicitWidth: 150
        implicitHeight: 40
        radius: Styles.radiusSm
        color: cardDrop.containsDrag ? theme.acent : theme.foreground
        z: dragArea.drag.active ? 100 : 1

        Drag.active: dragArea.drag.active
        Drag.keys: ["barWidget"]
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        TextStyled {
            anchors.left: parent.left
            anchors.leftMargin: Styles.marginSm
            anchors.verticalCenter: parent.verticalCenter
            color: theme.text
            text: card.widget
        }

        ButtonStyled {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            visible: card.sourceIndex >= 0
            text: "×"
            textColor: theme.text
            defaultColor: theme.background
            onClicked: root.removeEntry(card.sourceIndex)
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            anchors.rightMargin: card.sourceIndex >= 0 ? 40 : 0
            cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            drag.target: card
            onPressed: {
                card.dragStartX = card.x;
                card.dragStartY = card.y;
            }
            onReleased: {
                card.Drag.drop();
                card.x = card.dragStartX;
                card.y = card.dragStartY;
            }
        }

        DropArea {
            id: cardDrop
            anchors.fill: parent
            keys: ["barWidget"]
            enabled: card.sourceIndex >= 0
            onDropped: drop => {
                if (drop.source !== card) {
                    root.moveWidget(root.droppedSourceIndex(drop), root.droppedWidget(drop),
                        card.targetSection, card.targetPosition);
                    drop.acceptProposedAction();
                }
            }
        }
    }
}
