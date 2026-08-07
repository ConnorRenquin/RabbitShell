# AI Agent Guidelines & Project Context

Welcome, Agent! This document serves as your guide to understanding, modifying, and extending this custom **Quickshell** desktop shell. Please read this thoroughly before making any changes.

---

## 1. Project Overview & Architecture

This desktop shell is designed to be **extremely minimal, modular, and hackable**. Each component is intended to be self-contained and easily removable from `shell.qml` without breaking the rest of the system.

### Directory Structure

- `./` - Core entry point (`shell.qml`) and configuration files.
- `./Services` - Singletons (`pragma Singleton`) managing system-level states, data fetching, and IPC.
- `./Settings` - Styling, colors, icons, and persistent user settings.
- `/Components` - Reusable UI primitives (buttons, inputs, cards) used across modules.
- `/Modules` - High-level functional UI widgets/panels (e.g., `AppLauncher.qml`, `LockScreen.qml`, `Mixer.qml`).
- `/BarWidgets` - Specific widgets that populate the main desktop bar.

### Core Files

- `PatchBay.qml` - The central event bus used to pass signals between decoupled
  components (e.g., notifying the notification widget).
- `Utils.qml` & `Time.qml` - Core helper utilities with high dependency counts.
- `Settings.qml` - Manages persistent user settings (saved to `.data/settings.json`).
- `Colors.qml` & `Styles.qml` - Tailwind-like utility styling definitions.

---

## 2. Key Questions for Agents

Before you write a single line of code, you **must** ask and answer the following questions. If the answer is unclear, use search tools (`grep`, `find_path`) or ask the user for clarification.

### Architectural Alignment

1. **Is this a Service (state/logic) or a Module/Component (UI)?**
   - _Rule_: Keep UI components thin. Heavy logic, external process execution, or persistent state should live in a Service singleton.
2. **Does this feature need to communicate with other components?**
   - _Rule_: Do not tightly couple components. Use `qs.Services.PatchBay` to emit and listen to global events.
3. **Does this feature require persistent user configuration?**
   - _Rule_: Register new settings in `Settings.qml` using `register()`. Do not write custom file-saving logic unless absolutely necessary.

### Styling & Design

1. **Are we using the design system?**
   - _Rule_: Never hardcode hex colors or pixel dimensions if they can be derived from `qs.Settings.Colors` or `qs.Settings.Styles`.
2. **Is the layout responsive and Wayland-compatible?**
   - _Rule_: Ensure anchors, layouts, and window positioning respect different monitor sizes and scales using `qs.Services.MonitorInfo` or `qs.Services.HyprctlMonitors`.

### Performance & Safety

1. **Will this block the main QML thread?**
   - _Rule_: Never run blocking shell commands synchronously. Use asynchronous process execution (`Quickshell.execDetached` or async `Process` objects) and asynchronous file views (`FileView`).
2. **Is this command safe to run?**
   - _Rule_: Sanitize any user input before passing it to shell commands or IPC calls to prevent command injection.

---

## 3. Core Design Patterns & Examples

### A. Registering & Using Settings

To add a persistent setting, register it in `quickshell/Settings/Settings.qml#init()`:

```qml
register({
    name: 'myNewSetting',
    value: true, // Default value
    category: 'misc'
})
```

Then access or change it anywhere via the `Settings` singleton:

```qml
import qs.Settings

// Read
let val = Settings.get('myNewSetting').value;

// Write
Settings.change({ name: 'myNewSetting', value: false });
```

### B. Decoupled Communication via PatchBay

Avoid direct references between modules. Use `PatchBay.qml` to bridge them:

```qml
// In Services/PatchBay.qml (add your signal)
signal customEvent(var data)

// In the emitting component
PatchBay.customEvent(payload)

// In the receiving component
Connections {
    target: PatchBay
    function onCustomEvent(data) {
        // Handle event
    }
}
```

---

## Development & Testing Workflow

1. **Verify Syntax & Formatting**
   - Follow the rules in `.qmlformat.ini`.
2. **If taking a long time solving an issue prompt place console.logs around the problem area and prompt the user to show them**
3. **Check Logs**
   - Monitor stdout/stderr for QML binding loops, type mismatches, or missing
     import warnings.
