import QtQuick
import QtQuick.Layouts

import qs.Settings

Rectangle {
    id: root

    z: 5
    visible: false
    anchors.centerIn: parent
    width: 500
    height: column.implicitHeight + Styles.marginSm * 2
    radius: Styles.radiusLg
    color: Qt.lighter(Colors.surface, Colors.lighter)

    property alias title: header.text
    property alias currentText: textField.text
    property alias placeholderText: textField.placeholderText
    signal accepted

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginMd
        TextStyled {
            id: header
            visible: text
            Layout.fillWidth: true
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: Styles.radiusSm
            color: Colors.surface
            TextFieldStyled {
                id: textField
                anchors.fill: parent
            }
        }
        RowLayout {
            ButtonStyled {
                Layout.fillWidth: true
                text: 'accept'
                onClicked: {
                    root.accepted();
                    root.visible = false;
                }
            }
            ButtonStyled {
                text: 'cancel'
                Layout.fillWidth: true
                onClicked: root.visible = false
            }
        }
    }
}
