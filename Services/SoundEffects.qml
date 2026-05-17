pragma Singleton

import QtQuick

import Quickshell
import qs.Settings

Singleton {

    property var volume: Settings.get('soundEffectsVolume').value
    property bool effectsEnabled: Settings.get('soundEffectsEnabled').value

    function init() {
        console.log('SoundEffects -----------------------------------------');
        playWakeUp();
    }

    function playNotification() {
        playSoundEffect('Notification.wav');
    }

    function playError() {
        playSoundEffect('Error.wav');
    }

    function playUrgent() {
        playSoundEffect('Urgent.wav');
    }

    function playBlip() {
        playSoundEffect('Blip.wav');
    }

    function playWakeUp() {
        playSoundEffect('WakeUp.wav');
    }

    function playSoundEffect(effect: string) {
        if (!effectsEnabled) return
        var command = 'mpv .config/quickshell/SoundEffects/' + effect + ' --volume=' + volume
        Quickshell.execDetached(['bash', '-c', command])
    }
}
