import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Constants
import qs.Components

ListView {

    anchors.fill: parent
    anchors.margins: Styles.marginSm

    spacing: Styles.marginSm
    clip: true
    model: Object.keys(Styles.userStyles)

    ScrollBar.vertical: ScrollBar {
        active: true
        policy: ScrollBar.AsNeeded
    }
    delegate: Rectangle {
        id: settingEntry

        color: Colors.background
        implicitWidth: parent.width
        implicitHeight: 80
        radius: Styles.radiusSm

        required property string modelData
        required property int index
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Styles.marginSm

            TextStyled {
                text: settingEntry.modelData
            }

            TextFieldStyled {
                id: textField
                Layout.fillWidth: true

                Component.onCompleted: {
                    text = Styles.userStyles[settingEntry.modelData] || "";
                }

                Connections {
                    target: Styles
                    function onUserStylesChanged() {
                        textField.text = Styles.userStyles[settingEntry.modelData] || "";
                    }
                }

                onEditingFinished: {
                    var newStyles = Object.assign({}, Styles.userStyles);
                    if (settingEntry.modelData === "Font Family") {
                        newStyles[settingEntry.modelData] = text;
                    } else {
                        newStyles[settingEntry.modelData] = parseInt(text) || 0;
                    }
                    Styles.userStyles = newStyles;
                }
            }
        }
    }
}
