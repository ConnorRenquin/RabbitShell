pragma ComponentBehavior: Bound

import QtQuick

import qs.Settings
import qs.Services

Item {
    id: root

    property var peaks: Audio.peaks
    property int barCount: 56
    property int barWidth: 7
    property int barSpacing: 5
    property real minimumLevel: 0.06
    property real smoothingMs: 55
    property real spectrumSpread: 0.78
    property real peakBoost: 1.85
    property real attack: 0.72
    property real decay: 0.24
    property var animatedLevels: []
    property real animationPhase: 0
    property color color: Colors.onSurface
    property color shadowColor: Qt.darker(root.color, Colors.darker)
    property real inactiveOpacity: 0.28
    property bool mirrored: false

    readonly property real contentWidth: root.barCount * root.barWidth + Math.max(0, root.barCount - 1) * root.barSpacing

    implicitWidth: root.contentWidth
    implicitHeight: 90

    function clamp(value) {
        return Math.max(0, Math.min(1, value));
    }

    function peakAt(index) {
        if (!root.peaks || root.peaks.length === 0)
            return 0;

        if (root.peaks.length === 1)
            return root.clamp(root.peaks[0]);

        // Spread the available channel peaks across the meter instead of drawing each channel as one flat block.
        const channelIndex = index % root.peaks.length;
        const nextChannelIndex = (channelIndex + 1) % root.peaks.length;
        const mix = (index / Math.max(1, root.barCount - 1)) % 1;
        return root.clamp(root.peaks[channelIndex] * (1 - mix) + root.peaks[nextChannelIndex] * mix);
    }

    function maxPeak() {
        if (!root.peaks || root.peaks.length === 0)
            return 0;

        let peak = 0;
        for (let i = 0; i < root.peaks.length; i++)
            peak = Math.max(peak, root.peaks[i]);
        return root.clamp(peak);
    }

    function resizeLevels() {
        const levels = [];
        for (let i = 0; i < root.barCount; i++)
            levels.push(root.animatedLevels[i] ?? root.minimumLevel);
        root.animatedLevels = levels;
    }

    function pseudoRandom(index, salt) {
        return fract(Math.sin(index * 12.9898 + salt * 78.233) * 43758.5453);
    }

    function fract(value) {
        return value - Math.floor(value);
    }

    function targetLevelAt(index) {
        const globalPeak = root.maxPeak();
        if (globalPeak <= 0)
            return root.minimumLevel;

        // PwNodePeakMonitor exposes channel peaks, not FFT bins. These per-bar oscillators turn
        // the real peak envelope into independently moving pseudo bands instead of one shared wave.
        const position = index / Math.max(1, root.barCount - 1);
        const centerDistance = Math.abs(position - 0.5) * 2;
        const centerShape = Math.max(0.18, 1 - centerDistance * root.spectrumSpread);
        const channelPeak = root.peakAt(index);
        const shapedPeak = Math.pow(root.clamp((globalPeak * 0.72 + channelPeak * 0.58) * root.peakBoost), 0.72);
        const phase = root.animationPhase;
        const slow = 0.5 + 0.5 * Math.sin(phase * (1.2 + root.pseudoRandom(index, 1) * 2.8) + index * 0.73);
        const fast = 0.5 + 0.5 * Math.sin(phase * (4.5 + root.pseudoRandom(index, 2) * 6.0) + index * 2.17);
        const sparkle = Math.pow(root.pseudoRandom(index, Math.floor(phase * 10)), 2.4);
        const bandActivity = 0.18 + slow * 0.42 + fast * 0.28 + sparkle * 0.32;

        return Math.max(root.minimumLevel, root.clamp(shapedPeak * centerShape * bandActivity));
    }

    function levelAt(index) {
        if (!root.animatedLevels || root.animatedLevels.length <= index)
            return root.minimumLevel;
        return root.animatedLevels[index];
    }

    function barX(index) {
        return Math.max(0, (root.width - root.contentWidth) / 2) + index * (root.barWidth + root.barSpacing);
    }

    Component.onCompleted: root.resizeLevels()

    onBarCountChanged: root.resizeLevels()

    Timer {
        interval: 33
        running: true
        repeat: true

        onTriggered: {
            root.animationPhase += interval / 1000;

            const nextLevels = [];
            for (let i = 0; i < root.barCount; i++) {
                const current = root.animatedLevels[i] ?? root.minimumLevel;
                const target = root.targetLevelAt(i);
                const rate = target > current ? root.attack : root.decay * (0.55 + root.pseudoRandom(i, 7) * 0.7);
                nextLevels.push(current + (target - current) * rate);
            }
            root.animatedLevels = nextLevels;
        }
    }

    Repeater {
        model: root.barCount

        Rectangle {
            id: bar

            required property int index

            width: root.barWidth
            readonly property real level: root.levelAt(index)

            height: Math.max(root.barWidth, root.height * bar.level)
            radius: width / 2
            color: bar.level <= root.minimumLevel ? root.shadowColor : root.color
            opacity: bar.level <= root.minimumLevel ? root.inactiveOpacity : 1

            x: root.barX(index)
            y: root.mirrored ? 0 : root.height - height

            Behavior on height {
                NumberAnimation {
                    duration: root.smoothingMs
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.smoothingMs
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
