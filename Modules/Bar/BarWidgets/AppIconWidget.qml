import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

import QtQuick
import QtQuick.Layouts

import qs.Components.Plus
import qs.Components.Styled
import qs.Settings

Item {
	implicitWidth: icons.implicitWidth + Styles.marginSm
	RowLayoutPlus {
		id: icons
		anchors.centerIn: parent
		model: Hyprland.toplevels
		delegate: ButtonStyled {
			required property var modelData
			id: button
			Layout.preferredWidth: 35
			Layout.preferredHeight: 32
			onClicked: modelData.wayland.activate()
			IconImage {
				anchors.fill: parent
                implicitHeight: 24
                implicitWidth: 24
                source: Quickshell.iconPath(DesktopEntries.byId(button.modelData.wayland?.appId)?.icon, "applications-other")
            }
		}
	}
}
