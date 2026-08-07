import QtQuick
import qs.Settings

Canvas {
    id: dotGrid
    anchors.fill: parent

    readonly property real dotSpacing: Styles.marginSm
    readonly property real dotRadius: 2

    onDotSpacingChanged: requestPaint()
    onDotRadiusChanged: requestPaint()

    onPaint: {
        const context = getContext("2d");
        context.reset();
        context.fillStyle = 'white';
        context.globalAlpha = 0.2;

        for (let x = dotSpacing / 2; x < width; x += dotSpacing) {
            for (let y = dotSpacing / 2; y < height; y += dotSpacing) {
                context.beginPath();
                context.arc(x, y, dotRadius, 0, Math.PI * 2);
                context.fill();
            }
        }
    }
}
