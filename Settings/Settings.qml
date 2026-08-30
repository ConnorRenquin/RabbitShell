pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Components
import qs.Components.Plus
import qs.Settings.Models

Singleton {
    id: root


    function init() {
        console.log('Settings -----------------------------------------');
        register({
            name: 'clipboardLimit',
            value: 500
        })
        register({
            name: 'soundEffectsVolume',
            value: 70
        })
        register({
            name: 'soundEffectsEnabled',
            value: true
        })
        register({
            name: 'inhibitIdle',
            value:  false
        })
        register({
            name: 'lockTimeout',
            value:  60
        })
        register({
            name: 'suspendTimeout',
            value: 120
        })
        register({
            name: 'vimModeEnabled',
            value: false,
            category: 'misc'
        })
        register({
            name: 'toplevelLabel',
            value: 'title',
            options: ['title', 'appId'],
            category: 'appearance'
        })
        register({
            name: 'screenCaptureTargetMode',
            value: 'area',
            options: ['area', 'window', 'screen'],
            category: 'misc'
        })
        register({
            name: 'screenCaptureMode',
            value: 'copysave',
            options: ['copy', 'save', 'copysave'],
            category: 'misc'
        })
        register({
            name: 'screenCaptureDrawingTool',
            value: 'select',
            options: ['select', 'draw', 'line', 'box', 'erase'],
            category: 'misc'
        })
        register({
            name: 'screenCapturePaintColor',
            value: 'error',
            options: ['error', 'primary', 'tertiary', 'onSurface'],
            category: 'misc'
        })
        register({
            name: 'screenCaptureDelay',
            value: 0,
            options: [0, 3, 5, 10],
            category: 'misc'
        })
    }

    property var settings: []

    property var savedValues: ({})

    property bool isReady: false

    function register(setting) {
        const existing = settings.find(s => s.name === setting.name)
        if (existing) return existing

        const entry = {
            name:         setting.name,
            defaultValue: setting.value ?? null,
            value:        root.savedValues.hasOwnProperty(setting.name)
                              ? root.savedValues[setting.name]
                              : (setting.value ?? null),
            category:     setting.category ?? 'misc',
            type:         typeof setting.value,
            options:      setting.options ?? null,
        }
        settings = [...settings, entry]
        return entry
    }

    function change(setting) {
        const settingPosition = settings.findIndex(currentSetting => currentSetting.name === setting.name)
        if (settingPosition === -1) return register(setting)
        const updated = Object.assign({}, settings[settingPosition], setting)
        const next = [...settings]
        next[settingPosition] = updated
        settings = next
        return updated
    }

    function get(name) {
        return settings.find(s => s.name === name) ?? null
    }

    function getCategory(category) {
        return settings.filter(s => s.category === category)
    }

    function toDisplayName(name) {
        return name
            .replace(/([A-Z])/g, ' $1')
            .replace(/^./, s => s.toUpperCase())
    }

    function toSaveData() {
        // Start from the last-loaded saved values so that settings belonging to
        // components that haven't registered yet (e.g. wallpaper settings, which
        // only register when the settings panel is first opened) are never erased
        // by a save triggered while only core settings are registered.
        const out = Object.assign({}, root.savedValues)
        for (const s of settings) {
            if (s.value !== s.defaultValue) {
                out[s.name] = s.value
            } else {
                // Setting was reverted to default – remove it from the saved file.
                delete out[s.name]
            }
        }
        return out
    }

    onSettingsChanged: {
        if (root.isReady) {
            persistantData.save(root.toSaveData());
        }
    }

    FileViewPlus {
        id: persistantData
        path: Qt.resolvedUrl('./.data/settings.json')
        defaultValue: ({})

        onDataLoaded: parsed => {
            root.savedValues = parsed

            // When isReady is already true the reload was triggered by one of our
            // own save() calls.  Just refreshing savedValues (above) is enough –
            // the live settings array is already authoritative at that point.
            if (root.isReady)
                return

            const next = root.settings.map(s =>
                parsed.hasOwnProperty(s.name)
                    ? Object.assign({}, s, { value: parsed[s.name] })
                    : s
            )
            root.settings = next
            root.isReady = true
        }
    }
}
