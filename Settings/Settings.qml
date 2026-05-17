pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

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
        const out = {}
        for (const s of settings) {
            if (s.value !== s.defaultValue) {
                out[s.name] = s.value
            }
        }
        return out
    }

    onSettingsChanged: {
        if (root.isReady) {
            persistantData.setText(JSON.stringify(root.toSaveData(), null, 2))
        }
    }

    FileView {
        id: persistantData
        path: Qt.resolvedUrl('./.data/settings.json')
        blockLoading: false

        onLoaded: {
            try {
                const parsed = JSON.parse(persistantData.text())
                root.savedValues = parsed

                const next = root.settings.map(s =>
                    parsed.hasOwnProperty(s.name)
                        ? Object.assign({}, s, { value: parsed[s.name] })
                        : s
                )
                root.settings = next
            } catch (e) {
                console.log('Settings: failed to parse settings.json:', e)
                root.savedValues = ({})
            }
            root.isReady = true
        }

        onLoadFailed: {
            console.log('Settings: settings.json not found, creating...')
            Quickshell.execDetached(['touch', '.data/settings.json'])
            persistantData.setText('{}')
            root.isReady = true
        }

        onSaveFailed: console.log('Settings: failed to save settings.json')
    }
}
