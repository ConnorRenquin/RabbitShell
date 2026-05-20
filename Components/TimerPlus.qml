import QtQuick

Item {
    id: root

    property int interval: 1000 // Tick interval in ms
    property bool running: false
    property bool repeat: false
    property int duration: 0 // Total duration in seconds
    property int remaining: 0 // Remaining time in seconds
    property int elapsed: 0 // Elapsed time in seconds
    property bool paused: false

    signal triggered()
    signal tick()

    function start() {
        remaining = duration;
        elapsed = 0;
        paused = false;
        running = true;
        internalTimer.start();
    }

    function stop() {
        running = false;
        paused = false;
        internalTimer.stop();
    }

    function reset() {
        stop();
        remaining = duration;
        elapsed = 0;
    }

    function pause() {
        if (running && !paused) {
            paused = true;
            internalTimer.stop();
        }
    }

    function resume() {
        if (running && paused) {
            paused = false;
            internalTimer.start();
        }
    }

    function formatTime(seconds) {
        let hrs = Math.floor(seconds / 3600);
        let mins = Math.floor((seconds % 3600) / 60);
        let secs = seconds % 60;
        
        let res = "";
        if (hrs > 0) {
            res += (hrs < 10 ? "0" : "") + hrs + ":";
        }
        res += (mins < 10 ? "0" : "") + mins + ":";
        res += (secs < 10 ? "0" : "") + secs;
        return res;
    }

    readonly property string formattedRemaining: formatTime(remaining)
    readonly property string formattedElapsed: formatTime(elapsed)

    property Timer internalTimer: Timer {
        interval: root.interval
        repeat: true
        running: false
        onTriggered: {
            if (root.duration > 0) {
                root.remaining--;
                root.elapsed++;
                root.tick();
                if (root.remaining <= 0) {
                    root.running = false;
                    internalTimer.stop();
                    root.triggered();
                }
            } else {
                root.elapsed++;
                root.tick();
                if (!root.repeat) {
                    root.running = false;
                    internalTimer.stop();
                    root.triggered();
                }
            }
        }
    }
}
