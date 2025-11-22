import Quickshell
import QtQuick

import qs.Constants

Text {
    color: Colors.fg
    elide: Text.ElideRight
    anchors {
        left: parent.left
        right: parent.right
    }
    font {
        pixelSize: Styles.textMd
        family: "RobotoMono Nerd Font Propo"
        bold: true
    }
}
