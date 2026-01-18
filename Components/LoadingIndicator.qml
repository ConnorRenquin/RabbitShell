import QtQuick

import qs.Settings
import qs.Components

Item {
    id: root
    width: text.implicitWidth
    height: text.implicitHeight
    property bool running: true
    property int speed: 80 // Animation speed in milliseconds
    property string color: Colors.foreground

    // Braille animation symbols
    readonly property var brailleSymbols: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

    TextStyled {
        id: text
        anchors.centerIn: parent
        text: running ? brailleSymbols[currentFrame] : ""
        color: root.color
        font.family: Styles.nerdFontFamily // Use nerd font for proper braille symbols
    }

    property int currentFrame: 0

    Timer {
        id: animationTimer
        interval: root.speed
        running: root.running
        repeat: true
        onTriggered: {
            root.currentFrame = (root.currentFrame + 1) % root.brailleSymbols.length;
        }
    }
}
