import QtQuick

import qs.Settings
import qs.Services

TextEdit {
    Themer { id: theme }
    color: Colors.onSurface
    antialiasing: true
    verticalAlignment: Text.AlignVCenter
    selectedTextColor: theme.onMain
    selectionColor: theme.main
    font {
        pointSize: Styles.textMd
        family: Styles.defaultFontFamily
        bold: true
    }
}
