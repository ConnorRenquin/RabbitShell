import QtQuick
import "constants.js" as Constants

Rectangle {
    width: 70
    height: Constants.WIDGET_HEIGHT
    color: Colors.bgDim
    radius: 5

    Text {
        anchors.centerIn: parent
        text: Time.time
        color: Colors.fg
    }
}
