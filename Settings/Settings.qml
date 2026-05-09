pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    function init() {
        console.log('Settings -----------------------------------------');
    }

    // Internal JS array so standard array methods (.find, .filter, etc.) work.
    // Each entry shape: { name, defaultValue, value, category, type }
    // defaultValue mirrors setting.value at registration time and never changes —
    // it's used by toSaveData() to know what's actually been overridden.
    property var settings: []

    // Saved overrides loaded from disk: { [name]: value }
    // Held separately so register() can apply them to late-registering settings.
    property var savedValues: ({})

    // Only true after onLoaded or onLoadFailed fires.
    // Prevents onSettingsChanged from writing the file before it's been read.
    property bool isReady: false

    // Usage:
    //
    //   property var myFlag: Settings.register({
    //       name: 'My Flag',
    //       value: true,
    //       category: 'appearance'
    //   })
    //
    // Returns the existing entry if already registered (matched by name),
    // otherwise pushes a new entry and returns it.
    // Persisted overrides are applied automatically whether the file loaded
    // before or after this call.

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

    // Finds the setting by name and merges in the new fields.
    // Falls through to register() if it doesn't exist yet.
    function change(setting) {
        const idx = settings.findIndex(s => s.name === setting.name)
        if (idx === -1) return register(setting)

        const updated = Object.assign({}, settings[idx], setting)
        const next = [...settings]
        next[idx] = updated
        settings = next
        return updated
    }

    // Returns all settings whose category matches the given string.
    function getCategory(category) {
        return settings.filter(s => s.category === category)
    }

    // Convenience: look up a single setting by name.
    function get(name) {
        return settings.find(s => s.name === name) ?? null
    }

    // Converts a camelCase key into a human-readable Title Case label.
    // e.g. 'wallpaperTransitionDuration' -> 'Wallpaper Transition Duration'
    function toDisplayName(name) {
        return name
            .replace(/([A-Z])/g, ' $1')
            .replace(/^./, s => s.toUpperCase())
    }

    // Only serialise values that the user has actually changed from the default.
    // This keeps the file minimal and means new settings added in code always
    // start from their defaultValue rather than being overridden by a stale file.
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

                // Apply overrides to any settings that were already registered
                // before the file finished loading.
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
