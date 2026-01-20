import QtQuick

import qs.Components

TextStyled {
    id: root

    readonly property var brailleSymbols: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    property bool running: true
    property int speed: 80
    property int currentFrame: 0

    text: root.running ? root.brailleSymbols[root.currentFrame] : ""
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
