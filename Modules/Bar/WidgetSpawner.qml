pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.Modules.Bar.BarWidgets

Loader {
    id: root

    required property string widget
    property string monitorName: ""

    Layout.fillHeight: true
    sourceComponent: availableWidgets[widget] ?? null

    readonly property var availableWidgets: ({
        "appIconRow": appIconComponent,
        "battery": batteryComponent,
        "clock": clockComponent,
        "idleInhibitor": idleInhibitorComponent,
        "media": mediaComponent,
        "notifications": notificationsComponent,
        "systemTray": systemTrayComponent,
        "windowTitle": windowTitleComponent,
        "workspaces": workspacesComponent
    })

    Component { id: appIconComponent; AppIconWidget {} }
    Component { id: batteryComponent; BatteryWidget {} }
    Component { id: clockComponent; ClockWidget {} }
    Component { id: idleInhibitorComponent; IdleInhibitorWidget {} }
    Component { id: mediaComponent; MediaWidget {} }
    Component { id: notificationsComponent; NotificationsWidget {} }
    Component { id: systemTrayComponent; SystemTrayWidget {} }
    Component { id: windowTitleComponent; WindowTitleWidget {} }
    Component {
        id: workspacesComponent
        WorkspacesWidget {
            monitorName: root.monitorName
        }
    }
}
