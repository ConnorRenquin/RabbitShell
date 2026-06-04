import QtQuick
import QtQuick.Controls

import qs.Services
import qs.Settings
import qs.Helpers

ComboBox {
    id: root

    readonly property real delegateHeight: Math.ceil(font.pixelSize * 2.2)

    font.pointSize: Styles.textMd
    font.family: Styles.defaultFontFamily
    font.bold: true

    Themer {
        id: theme
    }

    background: Rectangle {
        color: Qt.darker(theme.background, Colors.darker)
        radius: Styles.radiusSm
        ColorAnimation on color {
            duration: 50
        }
    }

    contentItem: TextStyled {
        text: root.displayText
        verticalAlignment: Text.AlignVCenter
        leftPadding: Styles.marginSm
        rightPadding: root.indicator.width + Styles.marginSm
        elide: Text.ElideRight
    }

    popup: Popup {
        y: root.height + 2
        width: root.width
        implicitHeight: Math.min(contentItem.contentHeight, root.delegateHeight * 6) + 2
        padding: 1
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
        background: Rectangle {
            color: Qt.lighter(theme.background, 1.1)
            radius: Styles.radiusSm
        }
    }

    delegate: ItemDelegate {
        width: root.width
        height: root.delegateHeight
        highlighted: root.highlightedIndex === index
        contentItem: TextStyled {
            text: modelData
            verticalAlignment: Text.AlignVCenter
            leftPadding: Styles.marginSm
        }
        background: Rectangle {
            color: highlighted ? theme.foreground : "transparent"
            radius: Styles.radiusSm

            ColorAnimation on color {
                duration: 50
            }
        }
    }
}
