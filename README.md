# Resources
- Quickshell Site : https://quickshell.org/
- QML Language Reference : https://quickshell.org/docs/v0.1.0/guide/qml-language/
- Qt : https://doc.qt.io/


# About

https://github.com/user-attachments/assets/d5c31a74-d0c8-446a-aec3-19b4b3e868f4


This shell was built to be extremely minimal/hackable. Each file has the goal of being relevantly small and to-the-point, with basic styling to make things look pretty. Each item is intended to be modular. You can remove more or less any of 
the modules in `shell.qml` and have the rest of it work. Don't like a thing? Remove it! 

# Handles
-  Polkit
- Clipboard Management (Text only)
  - Images sometime in the future
- App Launcher
- Lock Screen

# Overview
`/` - This area contains all the core functional modules, as well as `shell.qml`
`/Services` - Primarily singletons with a few helper classes to help manage core systems
  - `PatchBay.qml` - Used to easily pass signals between components. e.g. NotificationWidget and the 
  NotificationManager
  - `Utils.qml & Time.qml` - These classes have the most dependents
`/Settings` - Just basic styling Settings. Similarly implemented like TailwindCSS
`/Components` - A few basic components to use throughout the project

# Install
1. In your `.config` clone this repo and rename it `quickshell`
2. Download the Dependenies in the dependency section.
4. Copy and import the `./quickshell.conf` file into your hyprland config.
- This file contains the defaulted keybinds.
- You can test it out before hand by running `quickshell` in your terminal

# Dependenies
- `ttf-roboto-mono-nerd` or another nerd font. You can configure this in the settings menu. 

```sh
hyprland
quickshell-git
pipewire
polkit
awww
hypridle
ttf-roboto-mono-nerd
```
