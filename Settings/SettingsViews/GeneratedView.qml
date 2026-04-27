import QtQuick

import qs.Components
import qs.Settings

Rectangle {
    id: root

    anchors.fill: parent
    color: Colors.surfaceLighter

    property string category: 'misc'

    ColumnLayoutPlus {
        model: Settings.getCategory(root.category)

        // will switch input for each type.
        // e.g. switch for bool/input box for string.
        delegate: Rectangle {}
    }
}
