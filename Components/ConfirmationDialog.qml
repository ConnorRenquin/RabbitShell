import QtQuick
import QtQuick.Layouts

import qs.Settings

Rectangle {
    id: root
    z: 5
    visible: false
    anchors.centerIn: parent
    color: Colors.backgroundHighlighted
    radius: Styles.radiusLg
    width: 400
    height: column.implicitHeight + Styles.marginSm * 2
    signal accepted
    signal canceled
    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm
        TextStyled {
            text: "Deleting file"
            Layout.fillWidth: true
        }
        TextStyled {
            text: GlobalSettings.currentTheme
            color: Colors.error
            Layout.fillWidth: true
        }
        Item {
            Layout.fillHeight: true
        }
        TextStyled {
            text: "This action cannot be undone."
            font.pixelSize: Styles.textSm
            color: Colors.warning
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
