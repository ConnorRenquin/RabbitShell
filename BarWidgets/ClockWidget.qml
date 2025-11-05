import QtQuick

import qs.Global
import qs.Constants
import qs.Services

BarWidget {
    implicitWidth: contentRow.implicitWidth + 20

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 20

        TextStyled {
            text: Time.time
        }

        TextStyled {
            text: ""
        }

        TextStyled {
            text: Time.date
        }
    }
}
