pragma ComponentBehavior: Bound

import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.Settings
import qs.Helpers
import qs.Components
import qs.Components.Plus
import qs.Components.Styled
import qs.Services

Rectangle {
    id: root

    color: "transparent"

    signal requestExit
    signal requestTabCycle(bool forward)

    visible: isActive
    property bool isActive: false
    property string searchText: ""
    property string selectedCategory: "all"
    property int selectedIndex: 0
    readonly property var categories: ["all", "faces", "reactions", "actions", "animals", "symbols", "dividers", "art"]
    focus: isActive

    property var filteredEmojis: {
        const query = searchText.trim().toLowerCase();
        return emojiList.filter(item => {
            const category = categoryFor(item);
            if (selectedCategory !== "all" && category !== selectedCategory)
                return false;
            if (query === "")
                return true;
            const result = utils.fuzzySearch(query, (item.name + " " + item.emoji + " " + category).toLowerCase());
            return result.matches;
        });
    }

    function categoryFor(item) {
        const name = item.name.toLowerCase();
        if (name.includes("divider") || name.includes("banner") || name.includes("progress"))
            return "dividers";
        if (item.art)
            return "art";

        const animals = ["bear", "dog", "cat", "fish", "butterfly", "squid", "bat", "penguin", "pig", "bunny", "owl", "kirby", "zoidberg"];
        if (animals.some(animal => name.includes(animal)))
            return "animals";

        const symbols = ["arrow", "checkbox", "copyright", "registered", "trademark", "infinity", "approximately", "equal", "degrees", "bullet", "stars set", "hearts set", "card suits", "weather", "chess", "moon", "flower", "star", "sun", "cloud", "snowman", "music", "check", "cross", "skull", "heart"];
        if (symbols.some(symbol => name.includes(symbol)))
            return "symbols";

        const actions = ["flip", "dance", "flex", "strong", "fight", "run", "wave", "hello", "bye", "thanks", "highfive", "point", "look", "hug", "kiss", "dab", "cheers", "gun", "sword", "magic", "wizard", "gimme"];
        if (actions.some(action => name.includes(action)))
            return "actions";

        const reactions = ["cry", "sad", "angry", "rage", "meh", "wtf", "wat", "omg", "surprised", "nope", "bored", "sleep", "tired", "thinking", "smirk", "blush", "disapprove", "approve", "success", "fail", "why", "confused", "help", "panic", "facepalm"];
        if (reactions.some(reaction => name.includes(reaction)))
            return "reactions";

        return "faces";
    }

    function navigationHandler(event) {
        if (controls.tabPressed(event)) {
            requestTabCycle(true);
            event.accepted = true;
            return true;
        }
        if (controls.backtabPressed(event)) {
            requestTabCycle(false);
            event.accepted = true;
            return true;
        }
        return false;
    }

    function copyEmoji(item, closeAfter = true) {
        ClipboardService.copyToClipboard(item.emoji, false);
        utils.notify({
            summary: "Copied: " + item.name,
            body: item.emoji
        });
        if (closeAfter)
            requestExit();
    }

    onVisibleChanged: {
        if (visible)
            Qt.callLater(() => searchField.forceActiveFocus());
    }

    Utils {
        id: utils
    }

    Controls {
        id: controls
    }

    Themer {
        id: theme
        settingName: 'clipboardColor'
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
        },
        {
            name: "sparkle divider",
            emoji: "✦•···············•✦"
        },
        {
            name: "star divider",
            emoji: "★━━━━━━━━━━━━━━━━━━━━★"
        },
        {
            name: "soft divider",
            emoji: "୨୧ ───────────── ୨୧"
        },
        {
            name: "wave divider",
            emoji: "～～～～～～～～～～～～"
        },
        {
            name: "dot divider",
            emoji: "· · ─────── ·𖥸· ─────── · ·"
        },
        {
            name: "music divider",
            emoji: "♫♪♩·.¸¸.·♩♪♫"
        },
        {
            name: "flower divider",
            emoji: "❀。• *₊°。 ❀°。"
        },
        {
            name: "warning banner",
            emoji: "⚠ ─── WARNING ─── ⚠"
        },
        {
            name: "arrow right long",
            emoji: "━━━━━━━▶"
        },
        {
            name: "arrow left long",
            emoji: "◀━━━━━━━"
        },
        {
            name: "double arrow",
            emoji: "«────── « ⋅ʚ♡ɞ⋅ » ──────»"
        },
        {
            name: "up arrow",
            emoji: "▲\n│\n│"
        },
        {
            name: "down arrow",
            emoji: "│\n│\n▼"
        },
        {
            name: "corner arrows",
            emoji: "↖  ↑  ↗\n←  ·  →\n↙  ↓  ↘",
            art: true
        },
        {
            name: "checkbox empty",
            emoji: "☐"
        },
        {
            name: "checkbox checked",
            emoji: "☑"
        },
        {
            name: "checkbox crossed",
            emoji: "☒"
        },
        {
            name: "copyright",
            emoji: "©"
        },
        {
            name: "registered",
            emoji: "®"
        },
        {
            name: "trademark",
            emoji: "™"
        },
        {
            name: "infinity",
            emoji: "∞"
        },
        {
            name: "approximately",
            emoji: "≈"
        },
        {
            name: "not equal",
            emoji: "≠"
        },
        {
            name: "less greater",
            emoji: "≤ ≥"
        },
        {
            name: "degrees",
            emoji: "°"
        },
        {
            name: "bullet set",
            emoji: "• ◦ ● ○ ◆ ◇ ■ □"
        },
        {
            name: "stars set",
            emoji: "★ ☆ ✦ ✧ ✩ ✪ ✫ ✬"
        },
        {
            name: "hearts set",
            emoji: "♥ ♡ ❤ ❥ ღ ۵"
        },
        {
            name: "card suits",
            emoji: "♠ ♣ ♥ ♦"
        },
        {
            name: "weather set",
            emoji: "☀ ☁ ☂ ☃ ☄"
        },
        {
            name: "chess set",
            emoji: "♔ ♕ ♖ ♗ ♘ ♙"
        },
        {
            name: "moon phases",
            emoji: "○ ◔ ◑ ◕ ●"
        },
        {
            name: "progress empty",
            emoji: "[░░░░░░░░░░] 0%"
        },
        {
            name: "progress half",
            emoji: "[█████░░░░░] 50%"
        },
        {
            name: "progress full",
            emoji: "[██████████] 100%"
        },
        {
            name: "loading dots",
            emoji: "[ •••      ]"
        },
        {
            name: "tiny cat",
            emoji: "/ᐠ｡ꞈ｡ᐟ\\"
        },
        {
            name: "cat loaf",
            emoji: "|\\__/,|   (`\\\n|_ _  |.--.) )\n( T   )     /\n(((^_(((/(((_/",
            art: true
        },
        {
            name: "bunny small",
            emoji: "(\\(\\\n( -.-)\no_(\")(\")",
            art: true
        },
        {
            name: "owl",
            emoji: " /\\_/\\\n((@v@))\n():::()\n VV-VV",
            art: true
        },
        {
            name: "fish swim",
            emoji: "><(((('>   <')))><"
        },
        {
            name: "rose",
            emoji: "@}--'--,--"
        },
        {
            name: "coffee cup",
            emoji: "  ( (\n   ) )\n........\n|      |]\n\\      /\n `----'",
            art: true
        },
        {
            name: "steam thumbs up",
            emoji: "░░░░░░░░░░░░▄▄\n░░░░░░░░░░░█░░█\n░░░░░░░░░░░█░░█\n░░░░░░░░░░█░░░█\n░░░░░░░░░█░░░░█\n██████▄▄▄█░░░░░██████▄\n▓▓▓▓▓█░░░░░░░░░░░░░░█\n▓▓▓▓▓█░░░░░░░░░░░░░░█\n▓▓▓▓▓█░░░░░░░░░░░░░░█\n▓▓▓▓▓█░░░░░░░░░░░░░░█\n▓▓▓▓▓█░░░░░░░░░░░░░░█\n▓▓▓▓▓█████░░░░░░░░░█\n█████▀░░░░▀▀██████▀",
            art: true
        },
        {
            name: "steam cat dots",
            emoji: "░░░░░░░░░░░░░░░░░░░░░░\n░░░░░▄▀▀▀▄░░░░░▄▀▀▀▄░░░\n░░░░█░░░░░█▄▄▄█░░░░░█░░\n░░░█░░░░░░░░░░░░░░░░░█░\n░░░█░░▄█▄░░░░░░░▄█▄░░█░\n░░░█░░░░░░░▄░▄░░░░░░░█░\n░░░░█░░░░░░░▀░░░░░░░█░░\n░░░░░▀▄▄▄▄▄▄▄▄▄▄▄▄▄▀░░░",
            art: true
        },
        {
            name: "steam heart dots",
            emoji: "░░░░░▄██▄░░░░▄██▄░░░░░\n░░░▄██████▄░▄██████▄░░░\n░░███████████████████░░\n░░███████████████████░░\n░░░█████████████████░░░\n░░░░███████████████░░░░\n░░░░░█████████████░░░░░\n░░░░░░███████████░░░░░░\n░░░░░░░█████████░░░░░░░\n░░░░░░░░███████░░░░░░░░\n░░░░░░░░░█████░░░░░░░░░\n░░░░░░░░░░███░░░░░░░░░░\n░░░░░░░░░░░█░░░░░░░░░░░",
            art: true
        },
        {
            name: "steam smile dots",
            emoji: "░░░░░░██████████░░░░░░\n░░░░██░░░░░░░░░░██░░░░\n░░██░░░░░░░░░░░░░░██░░\n░█░░░░██░░░░░░██░░░░█░\n█░░░░░██░░░░░░██░░░░░█\n█░░░░░░░░░░░░░░░░░░░░█\n█░░░░█░░░░░░░░░░█░░░░█\n░█░░░░██████████░░░░░█░\n░░██░░░░░░░░░░░░░░██░░\n░░░░██░░░░░░░░░░██░░░░\n░░░░░░██████████░░░░░░",
            art: true
        },
        {
            name: "steam doge dots",
            emoji: "░░░░░░░░░░░░░░░▄▄░░░░\n░░░░░░░░░░░░░░░█░░█░░░\n░░░░░░░░░░░░░░░█░░█░░░\n░░░░░░░░░░░░░░█░░░█░░░\n░░░░░░░░░░░░░█░░░░█░░░\n░░░░░░░░▄▄▄▄█░░░░░████\n░░░░░░░█░░░░░░░░░░░░░█\n░░░░░░░█░░░░░░░░░░░░░█\n░░░░░░░█░░░░░░░░░░░░░█\n░░░░░░░█░░░░░░░░░░░░░█\n░░░░░░░█░░░░░░░░░░░░░█\n░░░░░░░█████░░░░░░░░░█\n░░░░░░░░░░░░▀▀██████▀░",
            art: true
        },
        {
            name: "pixel space invader",
            emoji: "░░░░░▄▄▄▄▄▄▄░░░░░\n░░▄██▄░░░░░▄██▄░░\n▄██████▄░░▄██████▄\n██████████████████\n██░░██░░██░░██░░██\n░░░░████████░░░░\n░░██░░░░░░░░██░░\n██░░██░░░░██░░██",
            art: true
        },
        {
            name: "pixel ghost",
            emoji: "░░▄████████▄░░\n▄██▀░░░░░░▀██▄\n██░░██░░██░░██\n██░░██░░██░░██\n██░░░░▄▄░░░░██\n██░░░░░░░░░░██\n██░░██░░██░░██\n▀█▄▄██▄▄██▄▄█▀",
            art: true
        },
        {
            name: "welcome banner",
            emoji: "╔════════════════════╗\n║      WELCOME       ║\n╚════════════════════╝",
            art: true
        },
        {
            name: "gg banner",
            emoji: "┏━━━┓ ┏━━━┓\n┃┏━┓┃ ┃┏━┓┃\n┃┃ ┗┛ ┃┃ ┗┛\n┃┃┏━┓ ┃┃┏━┓\n┃┗┻━┃ ┃┗┻━┃\n┗━━━┛ ┗━━━┛",
            art: true
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: theme.foreground
            radius: Styles.radiusSm

            TextFieldStyled {
                id: searchField
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                placeholderText: "/search faces, symbols, dividers, or art"
                color: theme.text
                placeholderTextColor: theme.text
                onTextChanged: {
                    root.searchText = text;
                    root.selectedIndex = 0;
                }
                Keys.onPressed: event => {
                    if (root.navigationHandler(event))
                        return;
                    if (controls.escapePressed(event)) {
                        if (text !== "")
                            text = "";
                        else
                            root.requestExit();
                        event.accepted = true;
                    } else if (controls.downPressed(event)) {
                        emojiGrid.forceActiveFocus();
                        event.accepted = true;
                    }
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            orientation: ListView.Horizontal
            spacing: Styles.marginSm
            clip: true
            model: root.categories

            delegate: ButtonStyled {
                required property string modelData
                text: modelData === "all" ? "∞" : modelData
                implicitHeight: 30
                implicitWidth: Math.max(54, text.length * 9 + Styles.marginMd * 2)
                isFocused: root.selectedCategory === modelData
                defaultColor: isFocused ? theme.foreground : theme.background
                textColor: theme.text
                onClicked: {
                    root.selectedCategory = modelData;
                    root.selectedIndex = 0;
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            TextStyled {
                text: root.filteredEmojis.length + " " + (root.selectedCategory === "all" ? "ASCII items" : root.selectedCategory)
                color: theme.text
                font.pointSize: Styles.textSm
            }

            Item {
                Layout.fillWidth: true
            }

            TextStyled {
                text: "↵ copy  •  middle click keep open"
                color: theme.text
                font.pointSize: Styles.textXS
                opacity: 0.7
            }
        }

        ScrollView {
            id: emojiScroll
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentWidth: availableWidth

            GridLayoutPlus {
                id: emojiGrid
                focus: true
                columns: Math.max(1, Math.floor(width / 260))
                anchors.left: parent.left
                anchors.right: parent.right
                rowSpacing: Styles.marginSm
                columnSpacing: Styles.marginSm
                model: root.filteredEmojis

                Keys.onPressed: event => {
                    if (root.navigationHandler(event))
                        return;
                    if (controls.slashPressed(event)) {
                        searchField.forceActiveFocus();
                        event.accepted = true;
                    } else if (controls.escapePressed(event)) {
                        root.requestExit();
                        event.accepted = true;
                    } else if (controls.downPressed(event)) {
                        root.selectedIndex = Math.min(root.filteredEmojis.length - 1, root.selectedIndex + emojiGrid.columns);
                        event.accepted = true;
                    } else if (controls.upPressed(event)) {
                        root.selectedIndex = Math.max(0, root.selectedIndex - emojiGrid.columns);
                        event.accepted = true;
                    } else if (controls.rightPressed(event)) {
                        root.selectedIndex = Math.min(root.filteredEmojis.length - 1, root.selectedIndex + 1);
                        event.accepted = true;
                    } else if (controls.leftPressed(event)) {
                        root.selectedIndex = Math.max(0, root.selectedIndex - 1);
                        event.accepted = true;
                    } else if (controls.enterPressed(event) && root.filteredEmojis[root.selectedIndex]) {
                        root.copyEmoji(root.filteredEmojis[root.selectedIndex]);
                        event.accepted = true;
                    }
                }

                delegate: ButtonStyled {
                    id: emojiButton

                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: modelData.art ? 220 : 96
                    defaultColor: theme.background
                    radius: Styles.radiusMd
                    isFocused: root.selectedIndex === index

                    onClicked: mouse => root.copyEmoji(modelData, mouse.button !== Qt.MiddleButton)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.marginSm
                        spacing: Styles.marginXS

                        TextStyled {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: emojiButton.modelData.emoji
                            color: theme.text
                            font.pointSize: emojiButton.modelData.art ? 10 : 24
                            font.family: emojiButton.modelData.art ? "monospace" : Styles.defaultFontFamily
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: emojiButton.modelData.art ? Text.WrapAnywhere : Text.NoWrap
                            elide: emojiButton.modelData.art ? Text.ElideNone : Text.ElideRight
                        }

                        TextStyled {
                            Layout.fillWidth: true
                            text: emojiButton.modelData.name
                            color: theme.text
                            font.pointSize: Styles.textXS
                            horizontalAlignment: Text.AlignHCenter
                            opacity: 0.75
                        }
                    }
                }
            }
        }
    }
}
