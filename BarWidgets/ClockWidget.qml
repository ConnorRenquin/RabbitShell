import QtQuick

import qs.Components
import qs.Constants
import qs.Services

BarWidget {
    implicitWidth: contentRow.implicitWidth + Styles.margin * 2

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Styles.margin

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
