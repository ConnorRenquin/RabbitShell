# Resources
- Quickshell Site : https://quickshell.org/
- QML Language Reference : https://quickshell.org/docs/v0.1.0/guide/qml-language/

# About
This shell was built to be extermly minimal/hackable. Each file has the goal of being relevently small and too the point. 
With basic styling to make things look pretty. Each item is intended to be modular. You can remove more or less any of 
the modules in `shell.qml` and have the rest of it work. Don't like a thing? Remove it! 

# Overview
`/` - This area contains all the core functional modules, as well as `shell.qml`
`/Services` - Primarily singletons with a few helper classes to help manage core systems.
  - `PatchBay.qml` - Used to easliy pass signals between components. e.g. NotificationWidget and the 
  NotificationManager.
  - `Utils.qml & Time.qml` - These classs have the most dependents.
`/Constants` - Just basic styling constants. Similarly implemented like TailwindCSS
`/Components` - A few basic components to use throughout the project.

# Handles
-  Polkit
- Clipboard Management (Text only)
  - Images sometime in the future.
- App Launcher
- Lock Screen

# Dependenies
```sh
swww
hypridle
waypaper
roboto nerd font
```
