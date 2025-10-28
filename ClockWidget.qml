import QtQuick

Rectangle {
    width: 70
    height: Constants.widgetHeight
    color: Colors.bgDim
    radius: 5

    Text {
        anchors.centerIn: parent
        text: Time.time
        color: Colors.fg
    }
}
