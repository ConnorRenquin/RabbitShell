import Quickshell.Services.Mpris

import QtQuick
import QtQuick.Layouts

import qs.Settings

RowLayout {
    id: root

    required property MprisPlayer modelData
    property real previousVolume: 1.0
    property bool isCurrentItem: false

    spacing: Styles.marginSm

    function decrease() {
        slider.decrease();
    }

    function increase() {
        slider.increase();
    }

    function toggleMute() {
        root.modelData.togglePlaying();
    }

    TextStyled {
        text: ""
        font.pixelSize: Styles.textLg
    }
    Rectangle {
        color: root.isCurrentItem ? Colors.backgroundLifted : Colors.background
        Layout.fillWidth: !root.modelData.volumeSupported
        Layout.fillHeight: true
        Layout.preferredWidth: 150
        radius: Styles.radiusLg
        TextStyled {
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            text: root.modelData.identity + ' - ' + root.modelData.trackAlbum + ' - ' + root.modelData.trackTitle
        }
    }
    ButtonStyled {
        visible: root.modelData.canGoPrevious
        text: "󰒮"
        onClicked: root.modelData.previous()
    }
    ButtonStyled {
        visible: root.modelData.loopSupported
        text: {
            if (root.modelData.loopState === MprisLoopState.None)
                return "󰑗";
            if (root.modelData.loopState === MprisLoopState.Track)
                return "󰑘";
            if (root.modelData.loopState === MprisLoopState.Playlist)
                return "󰑖";
            return "";
        }
        isFocused: root.modelData.loopState !== MprisLoopState.None

        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (root.modelData.loopState === MprisLoopState.None) {
                    root.modelData.loopState = MprisLoopState.Playlist;
                } else if (root.modelData.loopState === MprisLoopState.Playlist) {
                    root.modelData.loopState = MprisLoopState.Track;
                } else {
                    root.modelData.loopState = MprisLoopState.None;
                }
            } else if (mouse.button === Qt.RightButton) {
                if (root.modelData.loopState === MprisLoopState.Track) {
                    root.modelData.loopState = MprisLoopState.Playlist;
                } else if (root.modelData.loopState === MprisLoopState.None) {
                    root.modelData.loopState = MprisLoopState.Track;
                } else {
                    root.modelData.loopState = MprisLoopState.None;
                }
            }
        }
    }
    ButtonStyled {
        visible: root.modelData.shuffleSupported
        text: root.modelData.shuffle ? "󰒟" : "󰒞"
        onClicked: root.modelData.shuffle = !root.modelData.shuffle
        isFocused: root.modelData.shuffle
    }
    ButtonStyled {
        visible: root.modelData.canTogglePlaying
        text: "󰐎"
        onClicked: root.modelData.togglePlaying()
        isFocused: root.modelData.isPlaying
    }
    ButtonStyled {
        visible: root.modelData.canGoNext
        text: "󰒭"
        onClicked: root.modelData.next()
    }
    SliderStyled {
        id: slider
        Layout.fillWidth: true
        visible: root.modelData.volumeSupported
        value: root.modelData.volume
        onValueChanged: root.modelData.volume = value
    }
    // SliderStyled {
    //     Layout.fillWidth: true
    //     value: root.modelData.position
    // }
}
