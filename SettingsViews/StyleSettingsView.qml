import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components

Rectangle {
    color: Colors.backgroundLifted

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayoutPlus {
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            model: Object.keys(Styles.userStyles)
            delegate: Rectangle {
                id: settingEntry

                color: Colors.background
                implicitWidth: parent?.width ?? 0
                implicitHeight: 100
                radius: Styles.radiusSm

                required property string modelData
                required property int index
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.marginSm

                    TextStyled {
                        text: settingEntry.modelData
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: textField.implicitHeight + Styles.marginSm * 2

                            color: Colors.backgroundLifted
                            radius: Styles.radiusSm

                            TextFieldStyled {
                                id: textField

                                anchors.fill: parent
                                anchors.margins: Styles.marginSm

                                Component.onCompleted: text = Styles.userStyles[settingEntry.modelData] || ""

                                Connections {
                                    target: Styles
                                    function onUserStylesChanged() {
                                        textField.text = Styles.userStyles[settingEntry.modelData] || "";
                                    }
                                }
                            }
                        }
                        ButtonStyled {
                            text: 'Apply'
                            Layout.fillHeight: true
                            onClicked: {
                                var newStyles = Object.assign({}, Styles.userStyles);
                                if (settingEntry.modelData === "Font Family") {
                                    newStyles[settingEntry.modelData] = text;
                                } else {
                                    newStyles[settingEntry.modelData] = parseInt(textField.text) || 0;
                                }
                                Styles.userStyles = newStyles;
                            }
                        }

                        ButtonStyled {
                            text: 'Reset'
                            Layout.fillHeight: true
                            onClicked: {
                                textField.text = Styles.userStyles[settingEntry.modelData];
                            }
                        }
                    }
                }
            }
        }
    }
}
