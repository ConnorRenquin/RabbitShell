import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Settings

Rectangle {
    id: root

    anchors.fill: parent
    color: Colors.surface

    property string category: 'misc'

    ScrollViewPlus {
        anchors.fill: parent
        anchors.margins: Styles.marginMd

        ColumnLayoutPlus {
            width: parent.width
            spacing: Styles.marginSm
            model: Settings.getCategory(root.category)

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index

                Layout.fillWidth: true
                Layout.preferredHeight: 40

                radius: Styles.radiusSm
                color: Colors.surfaceVariant

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Styles.marginMd
                    anchors.rightMargin: Styles.marginMd
                    spacing: Styles.marginMd

                    TextStyled {
                        Layout.fillWidth: true
                        text: Settings.toDisplayName(row.modelData.name)
                        font.pointSize: Styles.textMd
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    // array (options)
                    ComboBoxStyled {
                        visible: !!row.modelData.options
                        Layout.preferredWidth: 180
                        model: visible ? row.modelData.options : []
                        currentIndex: visible ? row.modelData.options.indexOf(row.modelData.value) : -1
                        onActivated: index => Settings.change({
                            name: row.modelData.name,
                            value: row.modelData.options[index]
                        })
                    }

                    // bool
                    SwitchStyled {
                        visible: typeof row.modelData.value === 'boolean'
                        checked: visible ? row.modelData.value : false
                        onToggled: Settings.change({
                            name: row.modelData.name,
                            value: checked
                        })
                    }

                    // number
                    Rectangle {
                        visible: row.modelData.type === 'number'
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 28
                        color: Colors.surface
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

                    // string
                    Rectangle {
                        visible: typeof row.modelData.value === 'string' && !row.modelData.options
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 28
                        color: Colors.surface
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
}
