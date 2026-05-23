import QtQuick
import QtQuick.Layouts

import qs.Settings
import qs.Services

Rectangle {
    id: root
    z: 5
    visible: false
    anchors.centerIn: parent
    color: Qt.lighter(Colors.surface, Colors.lighter)
    radius: Styles.radiusLg
    width: 400
    height: column.implicitHeight + Styles.marginSm * 2
    signal accepted
    signal canceled

    Themer {
        id: theme
        variant: 'tertiary'
    }
    property string title
    property string body
    property string warning
    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm
        TextStyled {
            visible: text
            text: root.title
            Layout.fillWidth: true
        }
        TextStyled {
            visible: text
            text: root.body
            color: Colors.error
            Layout.fillWidth: true
        }
        Item {
            Layout.fillHeight: true
        }
        TextStyled {
            visible: text
            text: root.warning
            font.pointSize: Styles.textSm
            color: theme.text
            Layout.fillWidth: true
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
                onClicked: {
                    root.canceled();
                    root.visible = false;
                }
            }
        }
    }
}
