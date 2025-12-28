pragma Singleton

import Quickshell

import QtQuick

Singleton {
    id: root

    readonly property var availableThemes: ["everforest-dark", "everforest-light", "nord", "dracula", "gruvbox-dark", "gruvbox-light", "catppuccin-mocha", "catppuccin-latte", "tokyo-night", "tokyo-night-day", "solarized-dark", "solarized-light", "rose-pine", "rose-pine-dawn", "basic-dark"]

    property string currentTheme: "everforest-dark"

    function setTheme(themeName) {
        if (availableThemes.includes(themeName)) {
            currentTheme = themeName;
            themeChanged();
        } else {
            console.warn("Theme not found:", themeName);
        }
    }

    readonly property var theme: {
        switch (currentTheme) {
        case "everforest-dark":
            return everforestDark;
        case "everforest-light":
            return everforestLight;
        case "nord":
            return nord;
        case "dracula":
            return dracula;
        case "gruvbox-dark":
            return gruvboxDark;
        case "gruvbox-light":
            return gruvboxLight;
        case "catppuccin-mocha":
            return catppuccinMocha;
        case "catppuccin-latte":
            return catppuccinLatte;
        case "tokyo-night":
            return tokyoNight;
        case "tokyo-night-day":
            return tokyoNightDay;
        case "solarized-dark":
            return solarizedDark;
        case "solarized-light":
            return solarizedLight;
        case "rose-pine":
            return rosePine;
        case "rose-pine-dawn":
            return rosePineDawn;
        case "basic-dark":
            return basicDark;
        default:
            return everforestDark;
        }
    }

    readonly property var everforestDark: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#2D353B"
        readonly property string backgroundDim: "#232A2E"
        readonly property string backgroundAlt: "#343F44"
        readonly property string foreground: "#D3C6AA"

        // Background levels (for layering)
        readonly property string bg0: "#2D353B"
        readonly property string bg1: "#343F44"
        readonly property string bg2: "#3D484D"
        readonly property string bg3: "#475258"
        readonly property string bg4: "#4F585E"
        readonly property string bg5: "#56635f"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#543A48"
        readonly property string backgroundError: "#514045"
        readonly property string backgroundSuccess: "#425047"
        readonly property string backgroundInfo: "#3A515D"
        readonly property string backgroundWarning: "#4D4C43"

        // Primary accent colors
        readonly property string primary: "#A7C080"      // green
        readonly property string secondary: "#7FBBB3"    // blue
        readonly property string accent: "#E69875"       // orange

        // Semantic colors
        readonly property string success: "#A7C080"      // green
        readonly property string error: "#E67E80"        // red (from statusline3)
        readonly property string warning: "#DBBC7F"      // yellow
        readonly property string info: "#7FBBB3"         // blue

        // Extended palette
        readonly property string orange: "#E69875"
        readonly property string yellow: "#DBBC7F"
        readonly property string green: "#A7C080"
        readonly property string aqua: "#83C092"
        readonly property string blue: "#7FBBB3"
        readonly property string purple: "#D699B6"

        // Grays
        readonly property string gray: "#7A8478"
        readonly property string grayLight: "#859289"
        readonly property string grayLighter: "#9DA9A0"
    }

    readonly property var everforestLight: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#FDF6E3"
        readonly property string backgroundDim: "#F4F0D9"
        readonly property string backgroundAlt: "#EFEBD4"
        readonly property string foreground: "#5C6A72"

        // Background levels
        readonly property string bg0: "#FDF6E3"
        readonly property string bg1: "#F4F0D9"
        readonly property string bg2: "#EFEBD4"
        readonly property string bg3: "#E6E2CC"
        readonly property string bg4: "#E0DCC7"
        readonly property string bg5: "#BDC3AF"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#F0DDE1"
        readonly property string backgroundError: "#FFEAE9"
        readonly property string backgroundSuccess: "#F0F5ED"
        readonly property string backgroundInfo: "#EDF4F5"
        readonly property string backgroundWarning: "#FFF9E8"

        // Primary accent colors
        readonly property string primary: "#8DA101"      // green
        readonly property string secondary: "#3A94C5"    // blue
        readonly property string accent: "#F85552"       // orange/red

        // Semantic colors
        readonly property string success: "#8DA101"
        readonly property string error: "#F85552"
        readonly property string warning: "#DFA000"
        readonly property string info: "#3A94C5"

        // Extended palette
        readonly property string orange: "#F85552"
        readonly property string yellow: "#DFA000"
        readonly property string green: "#8DA101"
        readonly property string aqua: "#35A77C"
        readonly property string blue: "#3A94C5"
        readonly property string purple: "#DF69BA"

        // Grays
        readonly property string gray: "#A6B0A0"
        readonly property string grayLight: "#939F91"
        readonly property string grayLighter: "#829181"
    }

    readonly property var nord: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#2E3440"
        readonly property string backgroundDim: "#242933"
        readonly property string backgroundAlt: "#3B4252"
        readonly property string foreground: "#ECEFF4"

        // Background levels
        readonly property string bg0: "#2E3440"
        readonly property string bg1: "#3B4252"
        readonly property string bg2: "#434C5E"
        readonly property string bg3: "#4C566A"
        readonly property string bg4: "#5E6779"
        readonly property string bg5: "#6D7688"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#5E4C5A"
        readonly property string backgroundError: "#5E3D40"
        readonly property string backgroundSuccess: "#3E4E41"
        readonly property string backgroundInfo: "#3A4D5E"
        readonly property string backgroundWarning: "#5E5340"

        // Primary accent colors
        readonly property string primary: "#88C0D0"
        readonly property string secondary: "#81A1C1"
        readonly property string accent: "#88C0D0"

        // Semantic colors
        readonly property string success: "#A3BE8C"
        readonly property string error: "#BF616A"
        readonly property string warning: "#EBCB8B"
        readonly property string info: "#88C0D0"

        // Extended palette
        readonly property string orange: "#D08770"
        readonly property string yellow: "#EBCB8B"
        readonly property string green: "#A3BE8C"
        readonly property string aqua: "#8FBCBB"
        readonly property string blue: "#81A1C1"
        readonly property string purple: "#B48EAD"

        // Grays
        readonly property string gray: "#4C566A"
        readonly property string grayLight: "#5E6779"
        readonly property string grayLighter: "#D8DEE9"
    }

    readonly property var dracula: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#282A36"
        readonly property string backgroundDim: "#1E1F29"
        readonly property string backgroundAlt: "#343746"
        readonly property string foreground: "#F8F8F2"

        // Background levels
        readonly property string bg0: "#282A36"
        readonly property string bg1: "#343746"
        readonly property string bg2: "#3E4153"
        readonly property string bg3: "#44475A"
        readonly property string bg4: "#565869"
        readonly property string bg5: "#6272A4"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#4D3E52"
        readonly property string backgroundError: "#50313B"
        readonly property string backgroundSuccess: "#2E4035"
        readonly property string backgroundInfo: "#2F4158"
        readonly property string backgroundWarning: "#4D4435"

        // Primary accent colors
        readonly property string primary: "#BD93F9"
        readonly property string secondary: "#8BE9FD"
        readonly property string accent: "#FF79C6"

        // Semantic colors
        readonly property string success: "#50FA7B"
        readonly property string error: "#FF5555"
        readonly property string warning: "#F1FA8C"
        readonly property string info: "#8BE9FD"

        // Extended palette
        readonly property string orange: "#FFB86C"
        readonly property string yellow: "#F1FA8C"
        readonly property string green: "#50FA7B"
        readonly property string aqua: "#8BE9FD"
        readonly property string blue: "#8BE9FD"
        readonly property string purple: "#BD93F9"

        // Grays
        readonly property string gray: "#6272A4"
        readonly property string grayLight: "#7A8AA4"
        readonly property string grayLighter: "#9AA2B4"
    }

    readonly property var gruvboxDark: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#282828"
        readonly property string backgroundDim: "#1D2021"
        readonly property string backgroundAlt: "#3C3836"
        readonly property string foreground: "#EBDBB2"

        // Background levels
        readonly property string bg0: "#282828"
        readonly property string bg1: "#3C3836"
        readonly property string bg2: "#504945"
        readonly property string bg3: "#665C54"
        readonly property string bg4: "#7C6F64"
        readonly property string bg5: "#928374"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#503946"
        readonly property string backgroundError: "#4D3638"
        readonly property string backgroundSuccess: "#3C4841"
        readonly property string backgroundInfo: "#384656"
        readonly property string backgroundWarning: "#4D4538"

        // Primary accent colors
        readonly property string primary: "#B8BB26"
        readonly property string secondary: "#83A598"
        readonly property string accent: "#FE8019"

        // Semantic colors
        readonly property string success: "#B8BB26"
        readonly property string error: "#FB4934"
        readonly property string warning: "#FABD2F"
        readonly property string info: "#83A598"

        // Extended palette
        readonly property string orange: "#FE8019"
        readonly property string yellow: "#FABD2F"
        readonly property string green: "#B8BB26"
        readonly property string aqua: "#8EC07C"
        readonly property string blue: "#83A598"
        readonly property string purple: "#D3869B"

        // Grays
        readonly property string gray: "#928374"
        readonly property string grayLight: "#A89984"
        readonly property string grayLighter: "#BDAE93"
    }

    readonly property var gruvboxLight: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#FBF1C7"
        readonly property string backgroundDim: "#F2E5BC"
        readonly property string backgroundAlt: "#EBDBB2"
        readonly property string foreground: "#3C3836"

        // Background levels
        readonly property string bg0: "#FBF1C7"
        readonly property string bg1: "#EBDBB2"
        readonly property string bg2: "#D5C4A1"
        readonly property string bg3: "#BDAE93"
        readonly property string bg4: "#A89984"
        readonly property string bg5: "#928374"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#F2D5DB"
        readonly property string backgroundError: "#FBDCDB"
        readonly property string backgroundSuccess: "#E8F0E5"
        readonly property string backgroundInfo: "#E5EFF5"
        readonly property string backgroundWarning: "#FFF4D5"

        // Primary accent colors
        readonly property string primary: "#79740E"
        readonly property string secondary: "#076678"
        readonly property string accent: "#AF3A03"

        // Semantic colors
        readonly property string success: "#79740E"
        readonly property string error: "#CC241D"
        readonly property string warning: "#D79921"
        readonly property string info: "#076678"

        // Extended palette
        readonly property string orange: "#D65D0E"
        readonly property string yellow: "#D79921"
        readonly property string green: "#79740E"
        readonly property string aqua: "#427B58"
        readonly property string blue: "#076678"
        readonly property string purple: "#8F3F71"

        // Grays
        readonly property string gray: "#928374"
        readonly property string grayLight: "#7C6F64"
        readonly property string grayLighter: "#665C54"
    }

    readonly property var catppuccinMocha: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#1E1E2E"
        readonly property string backgroundDim: "#181825"
        readonly property string backgroundAlt: "#313244"
        readonly property string foreground: "#CDD6F4"

        // Background levels
        readonly property string bg0: "#1E1E2E"
        readonly property string bg1: "#313244"
        readonly property string bg2: "#45475A"
        readonly property string bg3: "#585B70"
        readonly property string bg4: "#6C7086"
        readonly property string bg5: "#7F849C"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#4D3E52"
        readonly property string backgroundError: "#4D2E34"
        readonly property string backgroundSuccess: "#2E4D3A"
        readonly property string backgroundInfo: "#2E3E4D"
        readonly property string backgroundWarning: "#4D4230"

        // Primary accent colors
        readonly property string primary: "#89B4FA"
        readonly property string secondary: "#94E2D5"
        readonly property string accent: "#F5C2E7"

        // Semantic colors
        readonly property string success: "#A6E3A1"
        readonly property string error: "#F38BA8"
        readonly property string warning: "#F9E2AF"
        readonly property string info: "#89DCEB"

        // Extended palette
        readonly property string orange: "#FAB387"
        readonly property string yellow: "#F9E2AF"
        readonly property string green: "#A6E3A1"
        readonly property string aqua: "#94E2D5"
        readonly property string blue: "#89B4FA"
        readonly property string purple: "#CBA6F7"

        // Grays
        readonly property string gray: "#6C7086"
        readonly property string grayLight: "#7F849C"
        readonly property string grayLighter: "#9399B2"
    }

    readonly property var catppuccinLatte: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#EFF1F5"
        readonly property string backgroundDim: "#E6E9EF"
        readonly property string backgroundAlt: "#DCE0E8"
        readonly property string foreground: "#4C4F69"

        // Background levels
        readonly property string bg0: "#EFF1F5"
        readonly property string bg1: "#E6E9EF"
        readonly property string bg2: "#DCE0E8"
        readonly property string bg3: "#CCD0DA"
        readonly property string bg4: "#BCC0CC"
        readonly property string bg5: "#ACB0BE"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#F2D5E3"
        readonly property string backgroundError: "#F7D7DC"
        readonly property string backgroundSuccess: "#E0F0E5"
        readonly property string backgroundInfo: "#D9EEF7"
        readonly property string backgroundWarning: "#F7F0D9"

        // Primary accent colors
        readonly property string primary: "#1E66F5"
        readonly property string secondary: "#179299"
        readonly property string accent: "#EA76CB"

        // Semantic colors
        readonly property string success: "#40A02B"
        readonly property string error: "#D20F39"
        readonly property string warning: "#DF8E1D"
        readonly property string info: "#04A5E5"

        // Extended palette
        readonly property string orange: "#FE640B"
        readonly property string yellow: "#DF8E1D"
        readonly property string green: "#40A02B"
        readonly property string aqua: "#179299"
        readonly property string blue: "#1E66F5"
        readonly property string purple: "#8839EF"

        // Grays
        readonly property string gray: "#9CA0B0"
        readonly property string grayLight: "#8C8FA1"
        readonly property string grayLighter: "#7C7F93"
    }

    readonly property var tokyoNight: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#1A1B26"
        readonly property string backgroundDim: "#16161E"
        readonly property string backgroundAlt: "#24283B"
        readonly property string foreground: "#C0CAF5"

        // Background levels
        readonly property string bg0: "#1A1B26"
        readonly property string bg1: "#24283B"
        readonly property string bg2: "#2F3549"
        readonly property string bg3: "#3B4261"
        readonly property string bg4: "#414868"
        readonly property string bg5: "#565F89"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#4D3E52"
        readonly property string backgroundError: "#4D2E34"
        readonly property string backgroundSuccess: "#2E4D3A"
        readonly property string backgroundInfo: "#2E3E4D"
        readonly property string backgroundWarning: "#4D4230"

        // Primary accent colors
        readonly property string primary: "#7AA2F7"
        readonly property string secondary: "#7DCFFF"
        readonly property string accent: "#BB9AF7"

        // Semantic colors
        readonly property string success: "#9ECE6A"
        readonly property string error: "#F7768E"
        readonly property string warning: "#E0AF68"
        readonly property string info: "#7DCFFF"

        // Extended palette
        readonly property string orange: "#FF9E64"
        readonly property string yellow: "#E0AF68"
        readonly property string green: "#9ECE6A"
        readonly property string aqua: "#73DACA"
        readonly property string blue: "#7AA2F7"
        readonly property string purple: "#BB9AF7"

        // Grays
        readonly property string gray: "#565F89"
        readonly property string grayLight: "#787C99"
        readonly property string grayLighter: "#A9B1D6"
    }

    readonly property var tokyoNightDay: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#E1E2E7"
        readonly property string backgroundDim: "#D5D6DB"
        readonly property string backgroundAlt: "#DFE0E5"
        readonly property string foreground: "#3760BF"

        // Background levels
        readonly property string bg0: "#E1E2E7"
        readonly property string bg1: "#DFE0E5"
        readonly property string bg2: "#D0D1D6"
        readonly property string bg3: "#C4C6CD"
        readonly property string bg4: "#B7B9C0"
        readonly property string bg5: "#9699A3"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#E5D5E3"
        readonly property string backgroundError: "#F7D7DC"
        readonly property string backgroundSuccess: "#E0F0E5"
        readonly property string backgroundInfo: "#D9E5F7"
        readonly property string backgroundWarning: "#F7F0D9"

        // Primary accent colors
        readonly property string primary: "#2E7DE9"
        readonly property string secondary: "#0F4B6E"
        readonly property string accent: "#9854F1"

        // Semantic colors
        readonly property string success: "#587539"
        readonly property string error: "#F52A65"
        readonly property string warning: "#8C6C3E"
        readonly property string info: "#0F4B6E"

        // Extended palette
        readonly property string orange: "#B15C00"
        readonly property string yellow: "#8C6C3E"
        readonly property string green: "#587539"
        readonly property string aqua: "#0F4B6E"
        readonly property string blue: "#2E7DE9"
        readonly property string purple: "#9854F1"

        // Grays
        readonly property string gray: "#9699A3"
        readonly property string grayLight: "#6172B0"
        readonly property string grayLighter: "#4C5C96"
    }

    readonly property var solarizedDark: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#002B36"
        readonly property string backgroundDim: "#00212B"
        readonly property string backgroundAlt: "#073642"
        readonly property string foreground: "#839496"

        // Background levels
        readonly property string bg0: "#002B36"
        readonly property string bg1: "#073642"
        readonly property string bg2: "#0E4B59"
        readonly property string bg3: "#155A6A"
        readonly property string bg4: "#1C6A7C"
        readonly property string bg5: "#586E75"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#4D3E52"
        readonly property string backgroundError: "#4D2E34"
        readonly property string backgroundSuccess: "#2E4D3A"
        readonly property string backgroundInfo: "#2E3E4D"
        readonly property string backgroundWarning: "#4D4230"

        // Primary accent colors
        readonly property string primary: "#268BD2"
        readonly property string secondary: "#2AA198"
        readonly property string accent: "#D33682"

        // Semantic colors
        readonly property string success: "#859900"
        readonly property string error: "#DC322F"
        readonly property string warning: "#B58900"
        readonly property string info: "#268BD2"

        // Extended palette
        readonly property string orange: "#CB4B16"
        readonly property string yellow: "#B58900"
        readonly property string green: "#859900"
        readonly property string aqua: "#2AA198"
        readonly property string blue: "#268BD2"
        readonly property string purple: "#6C71C4"

        // Grays
        readonly property string gray: "#586E75"
        readonly property string grayLight: "#657B83"
        readonly property string grayLighter: "#839496"
    }

    readonly property var solarizedLight: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#FDF6E3"
        readonly property string backgroundDim: "#EEE8D5"
        readonly property string backgroundAlt: "#EEE8D5"
        readonly property string foreground: "#657B83"

        // Background levels
        readonly property string bg0: "#FDF6E3"
        readonly property string bg1: "#EEE8D5"
        readonly property string bg2: "#DDD6C1"
        readonly property string bg3: "#CCC5B0"
        readonly property string bg4: "#BBB4A0"
        readonly property string bg5: "#93A1A1"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#F2D5E3"
        readonly property string backgroundError: "#F7D7DC"
        readonly property string backgroundSuccess: "#E8F0E5"
        readonly property string backgroundInfo: "#E5EFF7"
        readonly property string backgroundWarning: "#F7F0D9"

        // Primary accent colors
        readonly property string primary: "#268BD2"
        readonly property string secondary: "#2AA198"
        readonly property string accent: "#D33682"

        // Semantic colors
        readonly property string success: "#859900"
        readonly property string error: "#DC322F"
        readonly property string warning: "#B58900"
        readonly property string info: "#268BD2"

        // Extended palette
        readonly property string orange: "#CB4B16"
        readonly property string yellow: "#B58900"
        readonly property string green: "#859900"
        readonly property string aqua: "#2AA198"
        readonly property string blue: "#268BD2"
        readonly property string purple: "#6C71C4"

        // Grays
        readonly property string gray: "#93A1A1"
        readonly property string grayLight: "#839496"
        readonly property string grayLighter: "#657B83"
    }

    readonly property var rosePine: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#191724"
        readonly property string backgroundDim: "#1F1D2E"
        readonly property string backgroundAlt: "#26233A"
        readonly property string foreground: "#E0DEF4"

        // Background levels
        readonly property string bg0: "#191724"
        readonly property string bg1: "#1F1D2E"
        readonly property string bg2: "#26233A"
        readonly property string bg3: "#2A2837"
        readonly property string bg4: "#393552"
        readonly property string bg5: "#524F67"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#4D3E52"
        readonly property string backgroundError: "#4D2E34"
        readonly property string backgroundSuccess: "#2E4D3A"
        readonly property string backgroundInfo: "#2E3E4D"
        readonly property string backgroundWarning: "#4D4230"

        // Primary accent colors
        readonly property string primary: "#9CCFD8"
        readonly property string secondary: "#31748F"
        readonly property string accent: "#EBBCBA"

        // Semantic colors
        readonly property string success: "#9CCFD8"
        readonly property string error: "#EB6F92"
        readonly property string warning: "#F6C177"
        readonly property string info: "#31748F"

        // Extended palette
        readonly property string orange: "#F6C177"
        readonly property string yellow: "#F6C177"
        readonly property string green: "#9CCFD8"
        readonly property string aqua: "#9CCFD8"
        readonly property string blue: "#31748F"
        readonly property string purple: "#C4A7E7"

        // Grays
        readonly property string gray: "#6E6A86"
        readonly property string grayLight: "#908CAA"
        readonly property string grayLighter: "#E0DEF4"
    }

    readonly property var rosePineDawn: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#FAF4ED"
        readonly property string backgroundDim: "#FFFAF3"
        readonly property string backgroundAlt: "#F2E9E1"
        readonly property string foreground: "#575279"

        // Background levels
        readonly property string bg0: "#FAF4ED"
        readonly property string bg1: "#FFFAF3"
        readonly property string bg2: "#F2E9E1"
        readonly property string bg3: "#E5DED6"
        readonly property string bg4: "#D7CFC7"
        readonly property string bg5: "#CECACD"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#F2D5E3"
        readonly property string backgroundError: "#F7D7DC"
        readonly property string backgroundSuccess: "#E8F0E5"
        readonly property string backgroundInfo: "#E5EFF7"
        readonly property string backgroundWarning: "#F7F0D9"

        // Primary accent colors
        readonly property string primary: "#56949F"
        readonly property string secondary: "#286983"
        readonly property string accent: "#D7827E"

        // Semantic colors
        readonly property string success: "#56949F"
        readonly property string error: "#B4637A"
        readonly property string warning: "#EA9D34"
        readonly property string info: "#286983"

        // Extended palette
        readonly property string orange: "#EA9D34"
        readonly property string yellow: "#EA9D34"
        readonly property string green: "#56949F"
        readonly property string aqua: "#56949F"
        readonly property string blue: "#286983"
        readonly property string purple: "#907AA9"

        // Grays
        readonly property string gray: "#9893A5"
        readonly property string grayLight: "#797593"
        readonly property string grayLighter: "#575279"
    }

    readonly property var basicDark: QtObject {
        // Base colors
        readonly property string transparent: "transparent"
        readonly property string background: "#0A0A0A"
        readonly property string backgroundDim: "#000000"
        readonly property string backgroundAlt: "#1A1A1A"
        readonly property string foreground: "#E0E0E0"

        // Background levels
        readonly property string bg0: "#0A0A0A"
        readonly property string bg1: "#1A1A1A"
        readonly property string bg2: "#2A2A2A"
        readonly property string bg3: "#3A3A3A"
        readonly property string bg4: "#4A4A4A"
        readonly property string bg5: "#5A5A5A"

        // Semantic backgrounds
        readonly property string backgroundVisual: "#2A2A3A"
        readonly property string backgroundError: "#3A2A2A"
        readonly property string backgroundSuccess: "#2A3A2A"
        readonly property string backgroundInfo: "#2A2A3A"
        readonly property string backgroundWarning: "#3A3A2A"

        // Primary accent colors
        readonly property string primary: "#FFFFFF"
        readonly property string secondary: "#C0C0C0"
        readonly property string accent: "#A0A0A0"

        // Semantic colors
        readonly property string success: "#60D060"
        readonly property string error: "#E06060"
        readonly property string warning: "#E0C060"
        readonly property string info: "#6090E0"

        // Extended palette
        readonly property string orange: "#E09060"
        readonly property string yellow: "#E0C060"
        readonly property string green: "#60D060"
        readonly property string aqua: "#60D0C0"
        readonly property string blue: "#6090E0"
        readonly property string purple: "#C060E0"

        // Grays
        readonly property string gray: "#6A6A6A"
        readonly property string grayLight: "#8A8A8A"
        readonly property string grayLighter: "#AAAAAA"
    }
}
