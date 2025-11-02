import QtQuick

Rectangle {
    width: 70
    height: Constants.widgetHeight
    color: Colors.bgDim
    radius: 5

    TextStyled {
        anchors.centerIn: parent
        text: Time.time
    }
}
