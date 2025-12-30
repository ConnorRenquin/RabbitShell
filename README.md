# Resources
- Quickshell Site : https://quickshell.org/
- QML Language Reference : https://quickshell.org/docs/v0.1.0/guide/qml-language/
- Qt : https://doc.qt.io/

# About
This shell was built to be extermly minimal/hackable. Each file has the goal of being relevently small and too the point. 
With basic styling to make things look pretty. Each item is intended to be modular. You can remove more or less any of 
the modules in `shell.qml` and have the rest of it work. Don't like a thing? Remove it! 

# Handles
-  Polkit
- Clipboard Management (Text only)
  - Images sometime in the future.
- App Launcher
- Lock Screen

# Overview
`/` - This area contains all the core functional modules, as well as `shell.qml`
`/Services` - Primarily singletons with a few helper classes to help manage core systems.
  - `PatchBay.qml` - Used to easliy pass signals between components. e.g. NotificationWidget and the 
  NotificationManager.
  - `Utils.qml & Time.qml` - These class have the most dependents.
`/Constants` - Just basic styling constants. Similarly implemented like TailwindCSS
`/Components` - A few basic components to use throughout the project.

# Install
1. In your `.config` clone this repo
2. Download the Dependenies in the dependency section.
4. Copy and import the `./quickshell.conf` file into your hyprland config.
- This file contains the defaulted keybinds.
3. Add `exec-once = quickshell` to your Hyprland config.
- You can test it out before hand by running `quickshell` in your terminal

# Dependenies
- `roboto nerd font` isn't techniqually required but if a nerd font is. You can choose your own in `./Components/TextStyled.qml`

```sh
quickshell-git
swww
hypridle
waypaper
roboto nerd font
```
