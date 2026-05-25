import QtQuick

import qs.Services
import qs.Settings
import qs.Helpers

TextEdit {
    Themer { id: theme }
    color: Colors.onSurface
    antialiasing: true
    verticalAlignment: Text.AlignVCenter
    selectedTextColor: theme.background
    selectionColor: theme.text
    font {
        pointSize: Styles.textMd
        family: Styles.defaultFontFamily
        bold: true
    }
}
