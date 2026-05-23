import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings

Rectangle {
    id: root

    property string category: 'misc'

    color: Colors.surface
    implicitHeight: column.implicitHeight

    ColumnLayoutPlus {
        id: column
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        spacing: Styles.marginSm
        model: Settings.getCategory(root.category)

        delegate: Rectangle {
            id: row

            required property var modelData
            required property int index

            Layout.fillWidth: true
            Layout.preferredHeight: 40

            radius: Styles.radiusSm
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: Styles.marginMd

                TextStyled {
                    Layout.fillWidth: true
                    text: Settings.toDisplayName(row.modelData.name)
                }
                ComboBoxStyled {
                    id: optionsArray
                    visible: !!row.modelData.options
                    Layout.fillHeight: true
                    model: visible ? row.modelData.options : []
                    currentIndex: visible ? row.modelData.options.indexOf(row.modelData.value) : -1
                    onActivated: index => Settings.change({
                        name: row.modelData.name,
                        value: row.modelData.options[index]
                    })
                }

                SwitchStyled {
                    id: boolSwitch
                    visible: typeof row.modelData.value === 'boolean'
                    checked: visible ? row.modelData.value : false
                    onToggled: Settings.change({
                        name: row.modelData.name,
                        value: checked
                    })
                }

                Rectangle {
                    id: numberInput
                    visible: row.modelData.type === 'number'
                    Layout.preferredWidth: 180
                    Layout.fillHeight: true
                    color: Qt.darker(Colors.background, Colors.darker)
                    radius: Styles.radiusSm

                    TextFieldStyled {
                        anchors.fill: parent
                        anchors.leftMargin: Styles.marginSm
                        anchors.rightMargin: Styles.marginSm
                        text: visible ? row.modelData.value : ''
                        placeholderText: '0'
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: {
                            const num = parseFloat(text)
                            if (!isNaN(num)) Settings.change({
                                name: row.modelData.name,
                                value: num
                            })
                        }
                    }
                }

                Rectangle {
                    id: stringInput
                    visible: typeof row.modelData.value === 'string' && !row.modelData.options
                    Layout.preferredWidth: 180
                    Layout.fillHeight: true
                    color: Qt.darker(Colors.background, Colors.darker)
                    radius: Styles.radiusSm

                    TextFieldStyled {
                        anchors.fill: parent
                        anchors.leftMargin: Styles.marginSm
                        anchors.rightMargin: Styles.marginSm
                        text: visible ? row.modelData.value : ''
                        placeholderText: row.modelData.name
                        onEditingFinished: Settings.change({
                            name: row.modelData.name,
                            value: text
                        })
                    }
                }
            }
        }
    }
}
