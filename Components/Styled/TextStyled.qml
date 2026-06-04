import QtQuick

import qs.Settings

Text {
    color: Colors.onSurface
    elide: Text.ElideRight
    antialiasing: true
    verticalAlignment: Text.AlignVCenter
    font {
        pointSize: Styles.textMd
        family: Styles.defaultFontFamily
        bold: true
    }
}
