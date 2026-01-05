import QtQuick
import QtQuick.Controls

import qs.Settings

ComboBox {
    id: root

    property color backgroundColor: Colors.background
    property color highlightColor: Colors.backgroundHighlighted
    property color textColor: Colors.foreground
    property color borderColor: Colors.backgroundHighlighted

    font.pixelSize: Styles.textMd
    font.family: Styles.defaultFontFamily
    font.bold: true

    background: Rectangle {
        color: root.backgroundColor
        radius: Styles.radiusSm
        border.width: 1
        border.color: root.borderColor

        Behavior on color {
            ColorAnimation {
                duration: 50
            }
        }
    }

    contentItem: TextStyled {
        text: root.displayText
        verticalAlignment: Text.AlignVCenter
        leftPadding: Styles.marginSm
        rightPadding: root.indicator.width + Styles.marginSm
        elide: Text.ElideRight
    }

    indicator: Canvas {
        id: canvas
        x: root.width - width - Styles.marginSm
        y: root.topPadding + (root.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: root
            function onPressedChanged() {
                canvas.requestPaint();
            }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = root.textColor;
            context.fill();
        }
    }

    popup: Popup {
        y: root.height + 2
        width: root.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: root.backgroundColor
            border.color: root.borderColor
            border.width: 1
            radius: Styles.radiusSm
        }
    }

    delegate: ItemDelegate {
        width: root.width
        contentItem: TextStyled {
            text: modelData
            verticalAlignment: Text.AlignVCenter
            leftPadding: Styles.marginSm
        }

        background: Rectangle {
            color: highlighted ? root.highlightColor : "transparent"
            radius: Styles.radiusSm

            Behavior on color {
                ColorAnimation {
                    duration: 50
                }
            }
        }

        highlighted: root.highlightedIndex === index
    }
}
