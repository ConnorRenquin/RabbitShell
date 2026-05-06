pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Components
import qs.Services

FloatingWindow {
    id: root

    visible: false
    title: 'Clipboard'

    implicitWidth: 700
    implicitHeight: 800
    color: "transparent"

    function exit() {
        root.visible = false;
        grab.active = false;
    }

    Utils {
        id: utils
    }

    Connections {
        target: PatchBay
        function onOpenAsciiEmojis() {
            root.visible = !root.visible;
            grab.active = root.visible;
            base.focus = root.visible;
        }
    }

    GlobalShortcut {
        name: 'asciimojis'
        onPressed: {
            root.visible = !root.visible;
            grab.active = root.visible;
            base.focus = root.visible;
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
    }

    property var emojiList: [
        {
            name: "shrug",
            emoji: "¯\\_(ツ)_/¯"
        },
        {
            name: "tableflip",
            emoji: "(ノ ゜Д゜)ノ ︵ ┻━┻"
        },
        {
            name: "unflip",
            emoji: "┬──┬ ノ(ò_óノ)"
        },
        {
            name: "lenny",
            emoji: "( ͡° ͜ʖ ͡°)"
        },
        {
            name: "happy",
            emoji: "٩( ๑╹ ꇴ╹)۶"
        },
        {
            name: "smile",
            emoji: "ツ"
        },
        {
            name: "cute",
            emoji: "(｡◕‿‿◕｡)"
        },
        {
            name: "heart",
            emoji: "♥"
        },
        {
            name: "bear",
            emoji: "ʕ·͡ᴥ·ʔ"
        },
        {
            name: "hug",
            emoji: "(づ｡◕‿‿◕｡)づ"
        },
        {
            name: "kiss",
            emoji: "(づ ￣ ³￣)づ"
        },
        {
            name: "love",
            emoji: "♥‿♥"
        },
        {
            name: "cry",
            emoji: "(╥﹏╥)"
        },
        {
            name: "sad",
            emoji: "ε(´סּ︵סּ`)з"
        },
        {
            name: "angry",
            emoji: "•`_´•"
        },
        {
            name: "rage",
            emoji: "t(ಠ益ಠt)"
        },
        {
            name: "meh",
            emoji: "ಠ_ಠ"
        },
        {
            name: "dealwithit",
            emoji: "(⌐■_■)"
        },
        {
            name: "cool",
            emoji: "(•_•) ( •_•)>⌐■-■ (⌐■_■)"
        },
        {
            name: "wink",
            emoji: "(͡° ͜ʖ ͡°)"
        },
        {
            name: "excited",
            emoji: "(ﾉ◕ヮ◕)ﾉ*:・ﾟ✧"
        },
        {
            name: "yay",
            emoji: "\\( ﾟヮﾟ)/"
        },
        {
            name: "dance",
            emoji: "ᕕ(⌐■_■)ᕗ ♪♬"
        },
        {
            name: "flexing",
            emoji: "ᕙ(`▽´)ᕗ"
        },
        {
            name: "strong",
            emoji: "ᕙ(⇀‸↼‶)ᕗ"
        },
        {
            name: "fight",
            emoji: "(ง •̀_•́)ง"
        },
        {
            name: "run",
            emoji: "(╯°□°)╯"
        },
        {
            name: "wave",
            emoji: "( * ^ *) ノシ"
        },
        {
            name: "hello",
            emoji: "(ʘ‿ʘ)╯"
        },
        {
            name: "bye",
            emoji: "(ʘ‿ʘ)╯"
        },
        {
            name: "thanks",
            emoji: "\\(^-^)/"
        },
        {
            name: "highfive",
            emoji: "._.)/\\(._."
        },
        {
            name: "facepalm",
            emoji: "(－‸ლ)"
        },
        {
            name: "wtf",
            emoji: "(⊙＿⊙')"
        },
        {
            name: "wat",
            emoji: "(ÒДÓױ)"
        },
        {
            name: "omg",
            emoji: "◕_◕"
        },
        {
            name: "surprised",
            emoji: "(๑•́ ヮ •̀๑)"
        },
        {
            name: "flower",
            emoji: "(✿◠‿◠)"
        },
        {
            name: "star",
            emoji: "★"
        },
        {
            name: "sun",
            emoji: "☀"
        },
        {
            name: "cloud",
            emoji: "☁"
        },
        {
            name: "snowman",
            emoji: "☃"
        },
        {
            name: "music",
            emoji: "♫"
        },
        {
            name: "check",
            emoji: "✔"
        },
        {
            name: "cross",
            emoji: "†"
        },
        {
            name: "skull",
            emoji: "☠"
        },
        {
            name: "peace",
            emoji: "✌(-‿-)✌"
        },
        {
            name: "point",
            emoji: "(☞ﾟヮﾟ)☞"
        },
        {
            name: "look",
            emoji: "(ಡ_ಡ)☞"
        },
        {
            name: "dog",
            emoji: "(◕ᴥ◕ʋ)"
        },
        {
            name: "cat",
            emoji: "(= ФェФ=)"
        },
        {
            name: "fish",
            emoji: "<\"(((<3"
        },
        {
            name: "butterfly",
            emoji: "ƸӜƷ"
        },
        {
            name: "squid",
            emoji: "<コ:彡"
        },
        {
            name: "bat",
            emoji: "/|\\ ^._.^ /|\\"
        },
        {
            name: "ghost",
            emoji: "༼ つ ╹ ╹ ༽つ"
        },
        {
            name: "bearhug",
            emoji: "ʕっ•ᴥ•ʔっ"
        },
        {
            name: "donger",
            emoji: "ヽ༼ຈل͜ຈ༽ﾉ"
        },
        {
            name: "lennyflip",
            emoji: "(ノ ͡° ͜ʖ ͡°ノ)   ︵ ( ͜。 ͡ʖ ͜。)"
        },
        {
            name: "rageflip",
            emoji: "(ノಠ益ಠ)ノ彡┻━┻"
        },
        {
            name: "bearflip",
            emoji: "ʕノ•ᴥ•ʔノ ︵ ┻━┻"
        },
        {
            name: "magic",
            emoji: "ヽ(｀Д´)⊃━☆ﾟ. * ･ ｡ﾟ,"
        },
        {
            name: "wizard",
            emoji: "╰( ͡° ͜ʖ ͡° )つ──☆*:・ﾟ"
        },
        {
            name: "sparkles",
            emoji: "(*・‿・)ノ⌒*:･ﾟ✧"
        },
        {
            name: "gimme",
            emoji: "༼ つ ◕_◕ ༽つ"
        },
        {
            name: "nope",
            emoji: "→_←"
        },
        {
            name: "kawaii",
            emoji: "≧◡≦"
        },
        {
            name: "woo",
            emoji: "＼(＾O＾)／"
        },
        {
            name: "yeah",
            emoji: "(•̀ᴗ•́)و ̑̑"
        },
        {
            name: "bored",
            emoji: "(-_-)"
        },
        {
            name: "sleep",
            emoji: "(-.-)Zzz..."
        },
        {
            name: "tired",
            emoji: "(=____=)"
        },
        {
            name: "nom",
            emoji: "(っˆڡˆς)"
        },
        {
            name: "thinking",
            emoji: "(¬‿¬)"
        },
        {
            name: "smirk",
            emoji: "¬‿¬"
        },
        {
            name: "innocent",
            emoji: "( ͡° ͜ʖ ͡°)"
        },
        {
            name: "dab",
            emoji: "ヽ( •_)ᕗ"
        },
        {
            name: "blush",
            emoji: "(˵ ͡° ͜ʖ ͡°˵)"
        },
        {
            name: "coffee",
            emoji: "c[_]"
        },
        {
            name: "beer",
            emoji: "🍺"
        },
        {
            name: "cheers",
            emoji: "※\\(^o^)/※"
        },
        {
            name: "disapprove",
            emoji: "ಠ_ಠ"
        },
        {
            name: "approve",
            emoji: "(☞ﾟヮﾟ)☞"
        },
        {
            name: "gun",
            emoji: "︻╦╤─"
        },
        {
            name: "sword",
            emoji: "o()xxxx[{::::::::::::::::::>"
        },
        {
            name: "zoidberg",
            emoji: "(V) (°,,,,°) (V)"
        },
        {
            name: "kirby",
            emoji: "(っ◔◡◔)っ"
        },
        {
            name: "penguin",
            emoji: "<(o.o<)"
        },
        {
            name: "pig",
            emoji: ":(￣(∞)￣):"
        },
        {
            name: "bunny",
            emoji: "(\\(\\  (-.-) /)/)"
        },
        {
            name: "robot",
            emoji: "d[ o_0 ]b"
        },
        {
            name: "alien",
            emoji: "༼ つ ◕_◕ ༽つ"
        },
        {
            name: "devil",
            emoji: "ψ(｀∇´)ψ"
        },
        {
            name: "angel",
            emoji: "☜(⌒▽⌒)☞"
        },
        {
            name: "zombie",
            emoji: "[¬º-°]¬"
        },
        {
            name: "success",
            emoji: "(•̀ᴗ•́)و"
        },
        {
            name: "fail",
            emoji: "(╯°□°）╯︵ ┻━┻"
        },
        {
            name: "dunnolol",
            emoji: "¯\\(°_o)/¯"
        },
        {
            name: "why",
            emoji: "ლ(`◉◞౪◟◉‵ლ)"
        },
        {
            name: "confused",
            emoji: "(•ิ_•ิ)?"
        },
        {
            name: "helpme",
            emoji: "\\(°Ω°)/"
        },
        {
            name: "panic",
            emoji: "(」°ロ°)」"
        }
    ]

    Rectangle {
        id: base

        anchors.fill: parent

        color: Colors.tertiaryContainer
        radius: Styles.radiusSm

        Keys.onPressed: event => {
            if ([Qt.Key_Escape, Qt.Key_Q].includes(event.key)) {
                root.exit();
                return;
            }
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: Styles.marginSm
            contentWidth: availableWidth
            GridLayoutPlus {
                id: emojiGrid
                columns: Math.floor(parent.width / 420)
                anchors.left: parent.left
                anchors.right: parent.right
                rowSpacing: Styles.marginSm
                columnSpacing: Styles.marginSm

                model: root.emojiList
                delegate: ButtonStyled {
                    id: emojiButton

                    required property var modelData
                    required property int index

                    defaultColor: Colors.tertiary
                    text: emojiButton.modelData.emoji
                    textColor: Colors.onTertiary
                    pointSize: 34

                    Layout.fillWidth: true
                    Layout.preferredHeight: 100

                    radius: Styles.radiusMd

                    onClicked: {
                        const emoji = emojiButton.modelData.emoji;
                        const escapedEmoji = emoji.replace(/'/g, "'\\''");
                        Quickshell.execDetached(['bash', '-c', "printf '%s' '" + escapedEmoji + "' | wl-copy"]);
                        utils.notify({
                            summary: 'Copied: ' + emojiButton.modelData.name,
                            body: emoji
                        });
                        root.exit();
                    }
                }
            }
        }
    }
}
