import QtQuick
import QtQuick.Layouts

import qs.Components.Styled
import qs.Services
import qs.Settings

ButtonStyled {
    visible: Notifications.notifications.values.length > 0
    Layout.fillHeight: true
    text: Icons.notificationBell + " " + Notifications.notifications.values.length
    onClicked: PatchBay.openNotificationsManager()
}
