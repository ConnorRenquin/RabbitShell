import QtQuick

import qs.Settings

TextEdit {
    color: Colors.onSurface
    antialiasing: true
    verticalAlignment: Text.AlignVCenter
    selectedTextColor: Colors.onPrimary
    selectionColor: Colors.primary
    font {
        pointSize: Styles.textMd
        family: Styles.defaultFontFamily
        bold: true
    }
}
