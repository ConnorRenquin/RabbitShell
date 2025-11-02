import QtQuick

Rectangle {
    id: clockBackground
    color: Colors.bgDim
    radius: 5
    height: Constants.widgetHeight

    implicitWidth: contentRow.implicitWidth + 20

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 20

        TextStyled {
            text: Time.time
        }

        TextStyled {
            text: ""
        }

        TextStyled {
            text: Time.date
        }
    }
}
