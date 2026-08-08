pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.Settings

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root

        required property var modelData

        property bool top: true
        property var barWidgets: Settings.get('barWidgets')?.value ?? []

        function widgetsFor(section) {
            return barWidgets.filter(entry => entry.section === section);
        }

        Component.onCompleted: {
            top = Settings.register({
                name: 'barPosition',
                value: true,
                category: 'appearance'
            }).value;
        }

        Connections {
            target: Settings
            function onSettingsChanged() {
                const s = Settings.settings.find(x => x.name === 'barPosition');
                if (s)
                    root.top = s.value;
            }
        }

        screen: modelData
        implicitHeight: 48
        color: "transparent"

        anchors {
            top: top
            left: true
            right: true
            bottom: !top
        }

        property int margin: Styles.marginSm
        margins {
            // Hyprland takes care of this margin, so you don't have to.
            top: top ? margin : 0
            bottom: top ? 0 : margin
            left: margin
            right: margin
        }

        Rectangle {
            id: barRect
            anchors.fill: parent
            radius: Styles.radiusMd

            property bool barBackground: true

            Component.onCompleted: {
                barBackground = Settings.register({
                    name: 'barBackground',
                    value: true,
                    category: 'appearance'
                }).value;
            }

            Connections {
                target: Settings
                function onSettingsChanged() {
                    const s = Settings.settings.find(x => x.name === 'barBackground');
                    if (s)
                        barRect.barBackground = s.value;
                }
            }

            color: barBackground ? Colors.background : 'transparent'
            BarRow {
                id: leftGroup
                anchors.left: parent.left

                Repeater {
                    model: root.widgetsFor('left')
                    delegate: WidgetSpawner {
                        required property var modelData
                        widget: modelData.widget
                        monitorName: root.modelData.name
                    }
                }
            }
            BarRow {
                id: centerGroup
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: root.widgetsFor('center')
                    delegate: WidgetSpawner {
                        required property var modelData
                        widget: modelData.widget
                        monitorName: root.modelData.name
                    }
                }
            }
            BarRow {
                id: rightGroup
                anchors.right: parent.right

                Repeater {
                    model: root.widgetsFor('right')
                    delegate: WidgetSpawner {
                        required property var modelData
                        widget: modelData.widget
                        monitorName: root.modelData.name
                    }
                }
            }
        }
    }

    component BarRow: RowLayout {
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        spacing: Styles.marginXS
    }

}
