pragma Singleton

import Quickshell

Singleton {
    function exec(command) {
        Quickshell.execDetached(["sh", "-c", command]);
    }

    function logout() {
        exec("hyprctl dispatch 'hl.dsp.exit()'")
    }

    function suspend() {
        exec("hyprctl dispatch 'hl.dsp.global(\"quickshell:lockscreen\")' && systemctl suspend")
    }

    function reboot() {
        exec("systemctl reboot || loginctl reboot")
    }

    function shutdown() {
        exec("systemctl poweroff || loginctl poweroff")
    }

    function firmware() {
        exec("systemctl reboot --firmware-setup || loginctl reboot --firmware-setup")
    }
}
