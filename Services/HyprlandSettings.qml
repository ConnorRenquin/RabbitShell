pragma Singleton

import Quickshell
import QtQuick
import QtCore as QtCoreLib

Singleton {
    id: root

    readonly property string homePath: String(QtCoreLib.StandardPaths.writableLocation(QtCoreLib.StandardPaths.HomeLocation)).replace("file://", "")
    readonly property string configDir: homePath + "/.config/hypr/quickshell"
    readonly property string configPath: configDir + "/init.lua"
    readonly property string configUrl: "file://" + configPath
    readonly property string monitorConfigPath: homePath + "/.config/hypr/monitors.lua"
    readonly property string monitorConfigUrl: "file://" + monitorConfigPath
    property var values: clone(defaultValues)
    property var monitorItems: []
    property var bindItems: []
    property var windowRuleItems: []
    property var layerRuleItems: []
    property var animationItems: []
    readonly property var bindFlagOptions: ["locked", "release", "click", "drag", "long_press", "repeating", "non_consuming", "mouse", "transparent", "ignore_mods", "separate", "bypass", "submap_universal"]
    readonly property var commonBindActions: [
        { id: "exec", label: "Application / shell command", param: "command", placeholder: "kitty" },
        { id: "global", label: "Quickshell global action", param: "target", placeholder: "quickshell:powermenu" },
        { id: "focusDirection", label: "Focus window direction", param: "direction", options: ["l", "r", "u", "d"] },
        { id: "moveWindowDirection", label: "Move window direction", param: "direction", options: ["l", "r", "u", "d"] },
        { id: "focusWorkspace", label: "Workspace focus", param: "workspace", placeholder: "1, r+1, empty" },
        { id: "moveWindowWorkspace", label: "Move window to workspace", param: "workspace", placeholder: "1, r+1, special" },
        { id: "moveWorkspaceMonitor", label: "Move workspace to monitor", param: "workspace", secondaryParam: "monitor", placeholder: "special", secondaryPlaceholder: "current" },
        { id: "grabWorkspace", label: "Grab workspace to current monitor", param: "workspace", placeholder: "1" },
        { id: "fullscreen", label: "Window fullscreen" },
        { id: "fullscreenState", label: "Window fullscreen state", param: "internal", secondaryParam: "client", placeholder: "0", secondaryPlaceholder: "3" },
        { id: "closeWindow", label: "Window close" },
        { id: "toggleFloating", label: "Window toggle floating" },
        { id: "dragWindow", label: "Window drag / mouse move" },
        { id: "resizeWindow", label: "Window resize / mouse resize" },
        { id: "toggleSplit", label: "Layout toggle split" },
        { id: "setLayout", label: "Layout set", param: "layout", options: ["dwindle", "master"] },
        { id: "toggleSpecialWorkspace", label: "Workspace toggle scratchpad" }
    ]

    readonly property var defaultValues: ({
            general: {
                border_size: 1,
                gaps_in: 5,
                gaps_out: 20,
                gaps_workspaces: 0,
                layout: "dwindle",
                resize_on_border: false,
                extend_border_grab_area: 15,
                hover_icon_on_border: true,
                allow_tearing: false,
                snap: {
                    enabled: false,
                    window_gap: 10,
                    monitor_gap: 10,
                    border_overlap: false,
                    respect_gaps: false
                }
            },
            decoration: {
                rounding: 0,
                rounding_power: 2.0,
                active_opacity: 0.1,
                inactive_opacity: 0.1,
                fullscreen_opacity: 0.1,
                dim_modal: true,
                dim_inactive: false,
                dim_strength: 0.5,
                dim_special: 0.2,
                dim_around: 0.4,
                screen_shader: "",
                border_part_of_window: true,
                blur: {
                    enabled: true,
                    size: 8,
                    passes: 1,
                    ignore_opacity: true,
                    new_optimizations: true,
                    xray: false,
                    noise: 0.0117,
                    contrast: 0.8916,
                    brightness: 0.8172,
                    vibrancy: 0.1696,
                    vibrancy_darkness: 0.0,
                    special: false,
                    popups: false,
                    popups_ignorealpha: 0.2,
                    input_methods: false,
                    input_methods_ignorealpha: 0.2
                },
                shadow: {
                    enabled: true,
                    range: 4,
                    render_power: 3,
                    sharp: false,
                    color: "0xee1a1a1a",
                    color_inactive: "",
                    offset: [0, 0],
                    scale: 1.0
                },
                glow: {
                    enabled: false,
                    range: 10,
                    render_power: 3,
                    color: "0xee1a1a1a",
                    color_inactive: ""
                }
            },
            animations: {
                enabled: true,
                workspace_wraparound: false
            },
            input: {
                kb_model: "",
                kb_layout: "us",
                kb_variant: "",
                kb_options: "",
                kb_rules: "",
                kb_file: "",
                numlock_by_default: false,
                resolve_binds_by_sym: false,
                repeat_rate: 25,
                repeat_delay: 600,
                sensitivity: 0.0,
                accel_profile: "",
                force_no_accel: false,
                left_handed: false,
                follow_mouse: 1,
                follow_mouse_threshold: 0.0,
                focus_on_close: 0,
                float_switch_override_focus: 1,
                touchpad: {
                    natural_scroll: false,
                    disable_while_typing: true,
                    scroll_factor: 1.0,
                    middle_button_emulation: false,
                    drag_lock: false
                }
            },
            gestures: {
                workspace_swipe_touch: false,
                workspace_swipe_touch_invert: false,
                workspace_swipe_distance: 300,
                workspace_swipe_invert: true,
                workspace_swipe_min_speed_to_force: 30,
                workspace_swipe_cancel_ratio: 0.5,
                workspace_swipe_create_new: true,
                workspace_swipe_forever: false,
                workspace_swipe_direction_lock: true,
                workspace_swipe_direction_lock_threshold: 10
            },
            group: {
                insert_after_current: true,
                focus_removed_window: true,
                drag_into_group: 1,
                merge_groups_on_drag: true,
                merge_groups_on_groupbar: true,
                auto_group: true,
                groupbar: {
                    enabled: true,
                    font_family: "Sans",
                    font_size: 8,
                    gradients: true,
                    height: 14,
                    indicator_height: 3,
                    stacked: false,
                    render_titles: true,
                    scrolling: true
                }
            },
            misc: {
                disable_hyprland_logo: false,
                disable_splash_rendering: false,
                force_default_wallpaper: -1,
                vrr: 0,
                mouse_move_enables_dpms: false,
                key_press_enables_dpms: false,
                always_follow_on_dnd: true,
                layers_hog_keyboard_focus: true,
                animate_manual_resizes: false,
                animate_mouse_windowdragging: false,
                disable_autoreload: false,
                enable_swallow: false,
                swallow_regex: "",
                swallow_exception_regex: "",
                focus_on_activate: false,
                mouse_move_focuses_monitor: true,
                render_unfocused_fps: 15,
                disable_xdg_env_checks: false,
                allow_session_lock_restore: false,
                close_special_on_empty: true,
                middle_click_paste: true
            },
            binds: {
                pass_mouse_when_bound: false,
                scroll_event_delay: 300,
                workspace_back_and_forth: false,
                allow_workspace_cycles: false,
                workspace_center_on: 0,
                focus_preferred_method: 0,
                ignore_group_lock: false,
                movefocus_cycles_fullscreen: false,
                disable_keybind_grabbing: false,
                window_direction_monitor_fallback: true
            },
            xwayland: {
                enabled: true,
                use_nearest_neighbor: true,
                force_zero_scaling: false,
                create_abstract_socket: false
            },
            opengl: {
                nvidia_anti_flicker: true
            },
            render: {
                direct_scanout: 0,
                expand_undersized_textures: true,
                xp_mode: false,
                ctm_animation: 2,
                send_content_type: true
            },
            cursor: {
                inactive_timeout: 0,
                no_hardware_cursors: 2,
                no_break_fs_vrr: 2,
                min_refresh_rate: 24,
                hotspot_padding: 1,
                enable_hyprcursor: true,
                hide_on_key_press: false,
                hide_on_touch: true,
                use_cpu_buffer: 2,
                warp_on_change_workspace: 0,
                default_monitor: "",
                zoom_factor: 1.0,
                zoom_rigid: false
            },
            ecosystem: {
                no_update_news: false,
                no_donation_nag: false
            },
            debug: {
                overlay: false,
                damage_tracking: 2,
                disable_logs: false,
                disable_time: true,
                enable_stdout_logs: false,
                damage_blink: false,
                disable_scale_checks: false
            }
        })

    readonly property var sections: [
        {
            title: "General",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/",
            subtitle: "Core Hyprland general variables.",
            settings: [
                {
                    path: "general.border_size",
                    label: "Border size",
                    type: "int",
                    min: 0,
                    max: 20
                },
                {
                    path: "general.gaps_in",
                    label: "Inner gaps",
                    type: "int",
                    min: 0,
                    max: 100
                },
                {
                    path: "general.gaps_out",
                    label: "Outer gaps",
                    type: "int",
                    min: 0,
                    max: 100
                },
                {
                    path: "general.gaps_workspaces",
                    label: "Workspace gaps",
                    type: "int",
                    min: 0,
                    max: 100
                },
                {
                    path: "general.layout",
                    label: "Layout",
                    type: "string",
                    options: ["dwindle", "master", "scrolling"]
                },
                {
                    path: "general.resize_on_border",
                    label: "Resize on border",
                    type: "bool"
                },
                {
                    path: "general.extend_border_grab_area",
                    visibleWhen: "general.resize_on_border",
                    label: "Border grab area",
                    type: "int",
                    min: 0,
                    max: 100
                },
                {
                    path: "general.hover_icon_on_border",
                    label: "Hover icon on border",
                    type: "bool",
                    visibleWhen: "general.resize_on_border"
                },
                {
                    path: "general.allow_tearing",
                    label: "Allow tearing",
                    type: "bool"
                }
            ]
        },
        {
            title: "Snap",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#snap",
            subtitle: "Subcategory general.snap.",
            settings: [
                {
                    path: "general.snap.enabled",
                    label: "Enabled",
                    type: "bool"
                },
                {
                    path: "general.snap.window_gap",
                    label: "Window gap",
                    type: "int",
                    visibleWhen: "general.snap.enabled"
                },
                {
                    path: "general.snap.monitor_gap",
                    label: "Monitor gap",
                    type: "int",
                    visibleWhen: "general.snap.enabled"
                },
                {
                    path: "general.snap.border_overlap",
                    label: "Border overlap",
                    type: "bool",
                    visibleWhen: "general.snap.enabled"
                },
                {
                    path: "general.snap.respect_gaps",
                    label: "Respect gaps",
                    type: "bool",
                    visibleWhen: "general.snap.enabled"
                }
            ]
        },
        {
            title: "Decoration",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#decoration",
            subtitle: "Basic Hyprland window decoration variables from decoration.",
            settings: [
                {
                    path: "decoration.rounding",
                    label: "Rounding",
                    type: "int",
                    min: 0,
                    max: 100,
                },
                {
                    path: "decoration.rounding_power",
                    label: "Rounding power",
                    type: "float",
                    min: 0,
                    max: 10,
                },
                {
                    path: "decoration.active_opacity",
                    label: "Active opacity",
                    type: "float",
                    min: 0.1,
                    max: 1.0,
                    step: 0.05
                },
                {
                    path: "decoration.inactive_opacity",
                    label: "Inactive opacity",
                    type: "float",
                    min: 0.1,
                    max: 1.0,
                    step: 0.05
                },
                {
                    path: "decoration.fullscreen_opacity",
                    label: "Fullscreen opacity",
                    type: "float",
                    min: 0.1,
                    max: 1.0,
                    step: 0.05
                },
                {
                    path: "decoration.dim_modal",
                    label: "Dim modal parents",
                    type: "bool"
                },
                {
                    path: "decoration.dim_inactive",
                    label: "Dim inactive windows",
                    type: "bool"
                },
                {
                    path: "decoration.dim_strength",
                    label: "Dim strength",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.05,
                    visibleWhen: "decoration.dim_inactive"
                },
                {
                    path: "decoration.dim_special",
                    label: "Special workspace dim",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.05
                },
                {
                    path: "decoration.dim_around",
                    label: "Dim around window rule",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.05
                },
                {
                    path: "decoration.screen_shader",
                    label: "Screen shader path",
                    type: "string",
                    omitWhenEmpty: true
                },
                {
                    path: "decoration.border_part_of_window",
                    label: "Border is part of window",
                    type: "bool"
                }
            ]
        },
        {
            title: "Blur",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#blur",
            subtitle: "Subcategory decoration.blur.",
            settings: [
                {
                    path: "decoration.blur.enabled",
                    label: "Enabled",
                    type: "bool"
                },
                {
                    path: "decoration.blur.size",
                    label: "Size",
                    type: "int",
                    min: 0,
                    max: 100,
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.passes",
                    label: "Passes",
                    type: "int",
                    min: 0,
                    max: 100,
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.ignore_opacity",
                    label: "Ignore opacity",
                    type: "bool",
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.new_optimizations",
                    label: "New optimizations",
                    type: "bool",
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.xray",
                    label: "Xray",
                    type: "bool",
                    visibleWhen: ["decoration.blur.enabled", "decoration.blur.new_optimizations"]
                },
                {
                    path: "decoration.blur.noise",
                    label: "Noise",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.contrast",
                    label: "Contrast",
                    type: "float",
                    min: 0.0,
                    max: 2.0,
                    step: 0.05,
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.brightness",
                    label: "Brightness",
                    type: "float",
                    min: 0.0,
                    max: 2.0,
                    step: 0.05,
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.vibrancy",
                    label: "Vibrancy",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.05,
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.vibrancy_darkness",
                    label: "Vibrancy darkness",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.05,
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.special",
                    label: "Blur special workspace",
                    type: "bool",
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.popups",
                    label: "Blur popups",
                    type: "bool",
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.popups_ignorealpha",
                    label: "Popup ignore alpha",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.05,
                    visibleWhen: ["decoration.blur.enabled", "decoration.blur.popups"]
                },
                {
                    path: "decoration.blur.input_methods",
                    label: "Blur input methods",
                    type: "bool",
                    visibleWhen: "decoration.blur.enabled"
                },
                {
                    path: "decoration.blur.input_methods_ignorealpha",
                    label: "Input method ignore alpha",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.05,
                    visibleWhen: ["decoration.blur.enabled", "decoration.blur.input_methods"]
                }
            ]
        },
        {
            title: "Shadow",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#shadow",
            subtitle: "Subcategory decoration.shadow.",
            settings: [
                {
                    path: "decoration.shadow.enabled",
                    label: "Enabled",
                    type: "bool"
                },
                {
                    path: "decoration.shadow.range",
                    label: "Range",
                    type: "int",
                    min: 0,
                    max: 10,
                    visibleWhen: "decoration.shadow.enabled"
                },
                {
                    path: "decoration.shadow.render_power",
                    label: "Render power",
                    type: "int",
                    min: 0,
                    max: 10,
                    visibleWhen: "decoration.shadow.enabled"
                },
                {
                    path: "decoration.shadow.sharp",
                    label: "Sharp",
                    type: "bool",
                    visibleWhen: "decoration.shadow.enabled"
                },
                {
                    path: "decoration.shadow.color",
                    label: "Color",
                    type: "raw",
                    visibleWhen: "decoration.shadow.enabled"
                },
                {
                    path: "decoration.shadow.color_inactive",
                    label: "Inactive color",
                    type: "raw",
                    visibleWhen: "decoration.shadow.enabled",
                    omitWhenEmpty: true
                },
                {
                    path: "decoration.shadow.offset",
                    label: "Offset",
                    type: "vector2",
                    visibleWhen: "decoration.shadow.enabled"
                },
                {
                    path: "decoration.shadow.scale",
                    label: "Scale",
                    type: "float",
                    min: 0.0,
                    max: 1.0,
                    step: 0.05,
                    visibleWhen: "decoration.shadow.enabled"
                }
            ]
        },
        {
            title: "Glow",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#glow",
            subtitle: "Subcategory decoration.glow.",
            settings: [
                {
                    path: "decoration.glow.enabled",
                    label: "Enabled",
                    type: "bool"
                },
                {
                    path: "decoration.glow.range",
                    label: "Range",
                    type: "int",
                    visibleWhen: "decoration.glow.enabled"
                },
                {
                    path: "decoration.glow.render_power",
                    label: "Render power",
                    type: "int",
                    visibleWhen: "decoration.glow.enabled"
                },
                {
                    path: "decoration.glow.color",
                    label: "Color",
                    type: "raw",
                    visibleWhen: "decoration.glow.enabled"
                },
                {
                    path: "decoration.glow.color_inactive",
                    label: "Inactive color",
                    type: "raw",
                    visibleWhen: "decoration.glow.enabled",
                    omitWhenEmpty: true
                }
            ]
        },
        {
            title: "Animations",
            wiki: "https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/",
            subtitle: "Global animation toggles. Per-animation rules can come later.",
            settings: [
                {
                    path: "animations.enabled",
                    label: "Enabled",
                    type: "bool"
                },
                {
                    path: "animations.workspace_wraparound",
                    label: "Workspace wraparound",
                    type: "bool",
                    visibleWhen: "animations.enabled"
                }
            ]
        },
        {
            title: "Input",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#input",
            subtitle: "Keyboard, mouse, and focus behavior.",
            settings: [
                {
                    path: "input.kb_model",
                    label: "Keyboard model",
                    type: "string",
                    omitWhenEmpty: true
                },
                {
                    path: "input.kb_layout",
                    label: "Keyboard layout",
                    type: "string"
                },
                {
                    path: "input.kb_variant",
                    label: "Keyboard variant",
                    type: "string",
                    omitWhenEmpty: true
                },
                {
                    path: "input.kb_options",
                    label: "Keyboard options",
                    type: "string",
                    omitWhenEmpty: true
                },
                {
                    path: "input.kb_rules",
                    label: "Keyboard rules",
                    type: "string",
                    omitWhenEmpty: true
                },
                {
                    path: "input.kb_file",
                    label: "Keyboard file",
                    type: "string",
                    omitWhenEmpty: true
                },
                {
                    path: "input.numlock_by_default",
                    label: "Numlock by default",
                    type: "bool"
                },
                {
                    path: "input.resolve_binds_by_sym",
                    label: "Resolve binds by symbol",
                    type: "bool"
                },
                {
                    path: "input.repeat_rate",
                    label: "Repeat rate",
                    type: "int"
                },
                {
                    path: "input.repeat_delay",
                    label: "Repeat delay",
                    type: "int"
                },
                {
                    path: "input.sensitivity",
                    label: "Pointer sensitivity",
                    type: "float"
                },
                {
                    path: "input.accel_profile",
                    label: "Acceleration profile",
                    type: "string",
                    options: ["", "adaptive", "flat", "custom"]
                },
                {
                    path: "input.force_no_accel",
                    label: "Force no acceleration",
                    type: "bool"
                },
                {
                    path: "input.left_handed",
                    label: "Left handed",
                    type: "bool"
                },
                {
                    path: "input.follow_mouse",
                    label: "Follow mouse",
                    type: "int",
                    options: ["Disabled", "Follow", "Detached", "Separate"],
                    optionValues: [0, 1, 2, 3]
                },
                {
                    path: "input.follow_mouse_threshold",
                    label: "Follow mouse threshold",
                    type: "float"
                },
                {
                    path: "input.focus_on_close",
                    label: "Focus on close",
                    type: "int",
                    options: ["Next", "Cursor", "MRU"],
                    optionValues: [0, 1, 2]
                },
                {
                    path: "input.float_switch_override_focus",
                    label: "Floating switch override focus",
                    type: "int",
                    options: ["Disabled", "Tiled/floating", "Also float-to-float"],
                    optionValues: [0, 1, 2]
                }
            ]
        },
        {
            title: "Touchpad",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#touchpad",
            subtitle: "Subcategory input.touchpad.",
            settings: [
                {
                    path: "input.touchpad.natural_scroll",
                    label: "Natural scroll",
                    type: "bool"
                },
                {
                    path: "input.touchpad.disable_while_typing",
                    label: "Disable while typing",
                    type: "bool"
                },
                {
                    path: "input.touchpad.scroll_factor",
                    label: "Scroll factor",
                    type: "float"
                },
                {
                    path: "input.touchpad.middle_button_emulation",
                    label: "Middle button emulation",
                    type: "bool"
                },
            ]
        },
        {
            title: "Gestures",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#gestures",
            subtitle: "Workspace swipe behavior.",
            settings: [
                {
                    path: "gestures.workspace_swipe_touch",
                    label: "Workspace swipe touch",
                    type: "bool"
                },
                {
                    path: "gestures.workspace_swipe_touch_invert",
                    label: "Invert touch swipe",
                    type: "bool",
                    visibleWhen: "gestures.workspace_swipe_touch"
                },
                {
                    path: "gestures.workspace_swipe_distance",
                    label: "Swipe distance",
                    type: "int",
                    visibleWhen: "gestures.workspace_swipe_touch"
                },
                {
                    path: "gestures.workspace_swipe_invert",
                    label: "Invert swipe",
                    type: "bool",
                    visibleWhen: "gestures.workspace_swipe_touch"
                },
                {
                    path: "gestures.workspace_swipe_min_speed_to_force",
                    label: "Min force speed",
                    type: "int",
                    visibleWhen: "gestures.workspace_swipe_touch"
                },
                {
                    path: "gestures.workspace_swipe_cancel_ratio",
                    label: "Cancel ratio",
                    type: "float",
                    visibleWhen: "gestures.workspace_swipe_touch"
                },
                {
                    path: "gestures.workspace_swipe_create_new",
                    label: "Create new workspace",
                    type: "bool",
                    visibleWhen: "gestures.workspace_swipe_touch"
                },
                {
                    path: "gestures.workspace_swipe_forever",
                    label: "Swipe forever",
                    type: "bool",
                    visibleWhen: "gestures.workspace_swipe_touch"
                },
                {
                    path: "gestures.workspace_swipe_direction_lock",
                    label: "Direction lock",
                    type: "bool",
                    visibleWhen: "gestures.workspace_swipe_touch"
                },
                {
                    path: "gestures.workspace_swipe_direction_lock_threshold",
                    label: "Direction lock threshold",
                    type: "int",
                    visibleWhen: ["gestures.workspace_swipe_touch", "gestures.workspace_swipe_direction_lock"]
                }
            ]
        },
        {
            title: "Group",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#group",
            subtitle: "Grouped window behavior.",
            settings: [
                {
                    path: "group.insert_after_current",
                    label: "Insert after current",
                    type: "bool"
                },
                {
                    path: "group.focus_removed_window",
                    label: "Focus removed window",
                    type: "bool"
                },
                {
                    path: "group.drag_into_group",
                    label: "Drag into group",
                    type: "int"
                },
                {
                    path: "group.merge_groups_on_drag",
                    label: "Merge groups on drag",
                    type: "bool"
                },
                {
                    path: "group.merge_groups_on_groupbar",
                    label: "Merge groups on groupbar",
                    type: "bool"
                },
                {
                    path: "group.auto_group",
                    label: "Auto group",
                    type: "bool"
                }
            ]
        },
        {
            title: "Groupbar",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#groupbar",
            subtitle: "Subcategory group.groupbar.",
            settings: [
                {
                    path: "group.groupbar.enabled",
                    label: "Enabled",
                    type: "bool"
                },
                {
                    path: "group.groupbar.font_family",
                    label: "Font family",
                    type: "string",
                    visibleWhen: "group.groupbar.enabled"
                },
                {
                    path: "group.groupbar.font_size",
                    label: "Font size",
                    type: "int",
                    visibleWhen: "group.groupbar.enabled"
                },
                {
                    path: "group.groupbar.gradients",
                    label: "Gradients",
                    type: "bool",
                    visibleWhen: "group.groupbar.enabled"
                },
                {
                    path: "group.groupbar.height",
                    label: "Height",
                    type: "int",
                    visibleWhen: "group.groupbar.enabled"
                },
                {
                    path: "group.groupbar.indicator_height",
                    label: "Indicator height",
                    type: "int",
                    visibleWhen: "group.groupbar.enabled"
                },
                {
                    path: "group.groupbar.stacked",
                    label: "Stacked",
                    type: "bool",
                    visibleWhen: "group.groupbar.enabled"
                },
                {
                    path: "group.groupbar.render_titles",
                    label: "Render titles",
                    type: "bool",
                    visibleWhen: "group.groupbar.enabled"
                },
                {
                    path: "group.groupbar.scrolling",
                    label: "Scrolling",
                    type: "bool",
                    visibleWhen: "group.groupbar.enabled"
                }
            ]
        },
        {
            title: "Misc",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#misc",
            subtitle: "Miscellaneous Hyprland behavior.",
            settings: [
                {
                    path: "misc.disable_hyprland_logo",
                    label: "Disable Hyprland logo",
                    type: "bool"
                },
                {
                    path: "misc.disable_splash_rendering",
                    label: "Disable splash rendering",
                    type: "bool"
                },
                {
                    path: "misc.force_default_wallpaper",
                    label: "Force default wallpaper",
                    type: "int"
                },
                {
                    path: "misc.vrr",
                    label: "VRR",
                    type: "int",
                    options: ["Off", "On", "Fullscreen", "Fullscreen game"],
                    optionValues: [0, 1, 2, 3]
                },
                {
                    path: "misc.mouse_move_enables_dpms",
                    label: "Mouse wakes DPMS",
                    type: "bool"
                },
                {
                    path: "misc.key_press_enables_dpms",
                    label: "Key press wakes DPMS",
                    type: "bool"
                },
                {
                    path: "misc.always_follow_on_dnd",
                    label: "Always follow on DnD",
                    type: "bool"
                },
                {
                    path: "misc.layers_hog_keyboard_focus",
                    label: "Layers hog keyboard focus",
                    type: "bool"
                },
                {
                    path: "misc.animate_manual_resizes",
                    label: "Animate manual resizes",
                    type: "bool"
                },
                {
                    path: "misc.animate_mouse_windowdragging",
                    label: "Animate mouse window dragging",
                    type: "bool"
                },
                {
                    path: "misc.disable_autoreload",
                    label: "Disable autoreload",
                    type: "bool"
                },
                {
                    path: "misc.enable_swallow",
                    label: "Enable swallow",
                    type: "bool"
                },
                {
                    path: "misc.swallow_regex",
                    label: "Swallow regex",
                    type: "string",
                    visibleWhen: "misc.enable_swallow",
                    omitWhenEmpty: true
                },
                {
                    path: "misc.swallow_exception_regex",
                    label: "Swallow exception regex",
                    type: "string",
                    visibleWhen: "misc.enable_swallow",
                    omitWhenEmpty: true
                },
                {
                    path: "misc.focus_on_activate",
                    label: "Focus on activate",
                    type: "bool"
                },
                {
                    path: "misc.mouse_move_focuses_monitor",
                    label: "Mouse move focuses monitor",
                    type: "bool"
                },
                {
                    path: "misc.render_unfocused_fps",
                    label: "Unfocused render FPS",
                    type: "int"
                },
                {
                    path: "misc.disable_xdg_env_checks",
                    label: "Disable XDG env checks",
                    type: "bool"
                },
                {
                    path: "misc.allow_session_lock_restore",
                    label: "Allow session lock restore",
                    type: "bool"
                },
                {
                    path: "misc.close_special_on_empty",
                    label: "Close special on empty",
                    type: "bool"
                },
                {
                    path: "misc.middle_click_paste",
                    label: "Middle click paste",
                    type: "bool"
                }
            ]
        },
        {
            title: "Binds",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Binds/",
            subtitle: "Global keybind behavior.",
            settings: [
                {
                    path: "binds.pass_mouse_when_bound",
                    label: "Pass mouse when bound",
                    type: "bool"
                },
                {
                    path: "binds.scroll_event_delay",
                    label: "Scroll event delay",
                    type: "int"
                },
                {
                    path: "binds.workspace_back_and_forth",
                    label: "Workspace back and forth",
                    type: "bool"
                },
                {
                    path: "binds.allow_workspace_cycles",
                    label: "Allow workspace cycles",
                    type: "bool"
                },
                {
                    path: "binds.workspace_center_on",
                    label: "Workspace center on",
                    type: "int"
                },
                {
                    path: "binds.focus_preferred_method",
                    label: "Focus preferred method",
                    type: "int"
                },
                {
                    path: "binds.ignore_group_lock",
                    label: "Ignore group lock",
                    type: "bool"
                },
                {
                    path: "binds.movefocus_cycles_fullscreen",
                    label: "Movefocus cycles fullscreen",
                    type: "bool"
                },
                {
                    path: "binds.disable_keybind_grabbing",
                    label: "Disable keybind grabbing",
                    type: "bool"
                },
                {
                    path: "binds.window_direction_monitor_fallback",
                    label: "Direction monitor fallback",
                    type: "bool"
                }
            ]
        },
        {
            title: "XWayland",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#xwayland",
            subtitle: "XWayland integration.",
            settings: [
                {
                    path: "xwayland.enabled",
                    label: "Enabled",
                    type: "bool"
                },
                {
                    path: "xwayland.use_nearest_neighbor",
                    label: "Nearest neighbor",
                    type: "bool",
                    visibleWhen: "xwayland.enabled"
                },
                {
                    path: "xwayland.force_zero_scaling",
                    label: "Force zero scaling",
                    type: "bool",
                    visibleWhen: "xwayland.enabled"
                },
                {
                    path: "xwayland.create_abstract_socket",
                    label: "Create abstract socket",
                    type: "bool",
                    visibleWhen: "xwayland.enabled"
                }
            ]
        },
        {
            title: "OpenGL / Render",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#render",
            subtitle: "Renderer-related options.",
            settings: [
                {
                    path: "opengl.nvidia_anti_flicker",
                    label: "NVIDIA anti flicker",
                    type: "bool"
                },
                {
                    path: "render.direct_scanout",
                    label: "Direct scanout",
                    type: "int",
                    options: ["Disable", "Enable", "Auto"],
                    optionValues: [0, 1, 2]
                },
                {
                    path: "render.expand_undersized_textures",
                    label: "Expand undersized textures",
                    type: "bool"
                },
                {
                    path: "render.xp_mode",
                    label: "XP mode",
                    type: "bool"
                },
                {
                    path: "render.ctm_animation",
                    label: "CTM animation",
                    type: "int"
                },
                {
                    path: "render.send_content_type",
                    label: "Send content type",
                    type: "bool"
                }
            ]
        },
        {
            title: "Cursor",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#cursor",
            subtitle: "Cursor rendering and hiding behavior.",
            settings: [
                {
                    path: "cursor.inactive_timeout",
                    label: "Inactive timeout",
                    type: "int"
                },
                {
                    path: "cursor.no_hardware_cursors",
                    label: "No hardware cursors",
                    type: "int",
                    options: ["Disabled", "Enabled", "Auto"],
                    optionValues: [0, 1, 2]
                },
                {
                    path: "cursor.no_break_fs_vrr",
                    label: "No break fullscreen VRR",
                    type: "int",
                    options: ["Disabled", "Enabled", "Auto"],
                    optionValues: [0, 1, 2]
                },
                {
                    path: "cursor.min_refresh_rate",
                    label: "Minimum refresh rate",
                    type: "int"
                },
                {
                    path: "cursor.hotspot_padding",
                    label: "Hotspot padding",
                    type: "int"
                },
                {
                    path: "cursor.enable_hyprcursor",
                    label: "Enable hyprcursor",
                    type: "bool"
                },
                {
                    path: "cursor.hide_on_key_press",
                    label: "Hide on key press",
                    type: "bool"
                },
                {
                    path: "cursor.hide_on_touch",
                    label: "Hide on touch",
                    type: "bool"
                },
                {
                    path: "cursor.use_cpu_buffer",
                    label: "Use CPU buffer",
                    type: "int",
                    options: ["Disabled", "Enabled", "Auto"],
                    optionValues: [0, 1, 2]
                },
                {
                    path: "cursor.warp_on_change_workspace",
                    label: "Warp on workspace change",
                    type: "int",
                    options: ["Disabled", "Enabled", "Force"],
                    optionValues: [0, 1, 2]
                },
                {
                    path: "cursor.default_monitor",
                    label: "Default monitor",
                    type: "string",
                    omitWhenEmpty: true
                },
                {
                    path: "cursor.zoom_factor",
                    label: "Zoom factor",
                    type: "float"
                },
                {
                    path: "cursor.zoom_rigid",
                    label: "Zoom rigid",
                    type: "bool"
                }
            ]
        },
        {
            title: "Keybind List",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Binds/",
            subtitle: "Add/edit generated hl.bind entries. These are appended after hl.config.",
            kind: "bindList",
            settings: [],
            editor: {
                kind: "bindList",
                addText: "+ Add keybind",
                titleKey: "keys",
                titleFallback: "New keybind",
                cardHeight: 250,
                rows: [
                    {
                        fields: [
                            {
                                type: "text",
                                key: "description",
                                label: "Name",
                                placeholder: "Launch terminal"
                            },
                            {
                                type: "text",
                                key: "keys",
                                label: "Keys",
                                placeholder: "SUPER + Return",
                                action: "captureBind"
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "combo",
                                key: "dispatcher",
                                label: "Dispatcher",
                                options: ["exec_cmd", "global", "raw", "callback"],
                                defaultValue: "exec_cmd"
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "text",
                                key: "argument",
                                label: "Argument",
                                placeholder: "kitty or quickshell:powermenu"
                            }
                        ]
                    },
                    {
                        type: "flags",
                        label: "Flags"
                    }
                ]
            }
        },
        {
            title: "Window Rules",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Window-Rules/",
            subtitle: "Add/edit generated hl.window_rule entries. These are appended after hl.config.",
            kind: "windowRuleList",
            settings: [],
            editor: {
                kind: "windowRuleList",
                addText: "+ Add window rule",
                titleKey: "name",
                titleFallback: "New window rule",
                cardHeight: 230,
                rows: [
                    {
                        fields: [
                            {
                                type: "text",
                                key: "name",
                                label: "Name",
                                placeholder: "Rule name"
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "text",
                                key: "matchClass",
                                label: "Class",
                                placeholder: "firefox|kitty"
                            },
                            {
                                type: "text",
                                key: "matchTitle",
                                label: "Title",
                                placeholder: "Settings",
                                secondary: true
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "bool",
                                key: "float",
                                label: "Float"
                            },
                            {
                                type: "bool",
                                key: "center",
                                label: "Center"
                            },
                            {
                                type: "bool",
                                key: "opaque",
                                label: "Opaque"
                            },
                            {
                                type: "bool",
                                key: "noBlur",
                                label: "No blur"
                            },
                            {
                                type: "bool",
                                key: "noShadow",
                                label: "No shadow"
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "text",
                                key: "size",
                                label: "Size",
                                placeholder: "500, monitor_h*0.5"
                            },
                            {
                                type: "text",
                                key: "move",
                                label: "Move",
                                placeholder: "cursor_x, cursor_y",
                                secondary: true
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "text",
                                key: "rounding",
                                label: "Rounding",
                                placeholder: "10",
                                numeric: true
                            }
                        ]
                    }
                ]
            }
        },
        {
            title: "Layer Rules",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Window-Rules/",
            subtitle: "Add/edit generated hl.layer_rule entries. These are appended after hl.config.",
            kind: "layerRuleList",
            settings: [],
            editor: {
                kind: "layerRuleList",
                addText: "+ Add layer rule",
                titleKey: "name",
                titleFallback: "New layer rule",
                cardHeight: 165,
                rows: [
                    {
                        fields: [
                            {
                                type: "text",
                                key: "name",
                                label: "Name",
                                placeholder: "Rule name"
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "text",
                                key: "namespace",
                                label: "Namespace",
                                placeholder: "notifications|toplevels"
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "bool",
                                key: "noAnim",
                                label: "No anim"
                            },
                            {
                                type: "bool",
                                key: "blur",
                                label: "Blur"
                            },
                            {
                                type: "bool",
                                key: "xray",
                                label: "Xray"
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "text",
                                key: "ignoreAlpha",
                                label: "Ignore alpha",
                                placeholder: "0.2",
                                numeric: true
                            }
                        ]
                    }
                ]
            }
        },
        {
            title: "Animation Rules",
            wiki: "https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/",
            subtitle: "Add/edit generated hl.animation entries. These are appended after hl.config.",
            kind: "animationList",
            settings: [],
            editor: {
                kind: "animationList",
                addText: "+ Add animation",
                titleKey: "leaf",
                titleFallback: "New animation",
                cardHeight: 165,
                rows: [
                    {
                        fields: [
                            {
                                type: "text",
                                key: "leaf",
                                label: "Leaf",
                                placeholder: "windowsIn"
                            },
                            {
                                type: "bool",
                                key: "enabled",
                                label: "Enabled",
                                defaultValue: true
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "text",
                                key: "speed",
                                label: "Speed",
                                placeholder: "4",
                                numeric: true,
                                stringify: true
                            }
                        ]
                    },
                    {
                        fields: [
                            {
                                type: "text",
                                key: "bezier",
                                label: "Bezier",
                                placeholder: "default"
                            },
                            {
                                type: "text",
                                key: "style",
                                label: "Style",
                                placeholder: "popin",
                                secondary: true
                            }
                        ]
                    }
                ]
            }
        },
        {
            title: "Ecosystem / Debug",
            wiki: "https://wiki.hypr.land/Configuring/Basics/Variables/#debug",
            subtitle: "Ecosystem notices and debugging options.",
            settings: [
                {
                    path: "ecosystem.no_update_news",
                    label: "No update news",
                    type: "bool"
                },
                {
                    path: "ecosystem.no_donation_nag",
                    label: "No donation nag",
                    type: "bool"
                },
                {
                    path: "debug.overlay",
                    label: "Debug overlay",
                    type: "bool"
                },
                {
                    path: "debug.damage_tracking",
                    label: "Damage tracking",
                    type: "int"
                },
                {
                    path: "debug.disable_logs",
                    label: "Disable logs",
                    type: "bool"
                },
                {
                    path: "debug.disable_time",
                    label: "Disable time in logs",
                    type: "bool"
                },
                {
                    path: "debug.enable_stdout_logs",
                    label: "Enable stdout logs",
                    type: "bool"
                },
                {
                    path: "debug.damage_blink",
                    label: "Damage blink",
                    type: "bool"
                },
                {
                    path: "debug.disable_scale_checks",
                    label: "Disable scale checks",
                    type: "bool"
                }
            ]
        }
    ]

    function clone(value) {
        return JSON.parse(JSON.stringify(value));
    }

    function mergeDefaults(parsed) {
        var merged = clone(defaultValues);
        if (parsed) {
            mergeObject(merged, parsed);
        }
        return merged;
    }

    function mergeObject(target, source) {
        for (var key in source) {
            if (source[key] !== undefined && source[key] !== null && typeof source[key] === "object" && !Array.isArray(source[key]) && typeof target[key] === "object") {
                mergeObject(target[key], source[key]);
            } else if (target[key] !== undefined) {
                target[key] = source[key];
            }
        }
    }

    function getPath(path) {
        return getPathFrom(values, path);
    }

    function getDefaultPath(path) {
        return getPathFrom(defaultValues, path);
    }

    function getPathFrom(source, path) {
        if (typeof path !== "string") {
            return undefined;
        }
        var parts = path.split(".");
        var cursor = source;
        for (var i = 0; i < parts.length; i++) {
            if (cursor === undefined || cursor === null)
                return undefined;
            cursor = cursor[parts[i]];
        }
        return cursor;
    }

    function settingDefinition(path) {
        for (var s = 0; s < sections.length; s++) {
            var settings = sections[s].settings;
            for (var i = 0; i < settings.length; i++) {
                if (settings[i].path === path)
                    return settings[i];
            }
        }
        return null;
    }

    function normalizeValue(path, value) {
        var setting = settingDefinition(path);
        if (setting && setting.type === "vector2") {
            if (Array.isArray(value))
                return [parseFloat(value[0]) || 0, parseFloat(value[1]) || 0];
            var text = String(value || "");
            var matches = text.match(/-?\d+(?:\.\d+)?/g) || [];
            return [parseFloat(matches[0]) || 0, parseFloat(matches[1]) || 0];
        }
        if (setting && typeof value === "number") {
            if (setting.min !== undefined && value < setting.min)
                return setting.min;
            if (setting.max !== undefined && value > setting.max)
                return setting.max;
        }
        return value;
    }

    function setPath(path, value) {
        value = normalizeValue(path, value);
        var next = clone(values);
        var parts = path.split(".");
        var cursor = next;
        for (var i = 0; i < parts.length - 1; i++) {
            cursor = cursor[parts[i]];
        }
        cursor[parts[parts.length - 1]] = value;
        values = next;
    }

    function parseInput(text, type) {
        if (type === "bool")
            return text === true || text === "true";
        if (type === "int") {
            var parsedInt = parseInt(text);
            return isNaN(parsedInt) ? 0 : parsedInt;
        }
        if (type === "float") {
            var parsedFloat = parseFloat(text);
            return isNaN(parsedFloat) ? 0 : parsedFloat;
        }
        if (type === "vector2") {
            var matches = String(text || "").match(/-?\d+(?:\.\d+)?/g) || [];
            return [parseFloat(matches[0]) || 0, parseFloat(matches[1]) || 0];
        }
        return String(text);
    }

    function displayValue(path) {
        var value = getPath(path);
        if (Array.isArray(value))
            return value.join(", ");
        return value === undefined || value === null ? "" : String(value);
    }

    function vector2Component(path, index) {
        var value = normalizeValue(path, getPath(path));
        return value[index] !== undefined ? value[index] : 0;
    }

    function setVector2Component(path, index, componentValue) {
        var value = normalizeValue(path, getPath(path));
        value[index] = parseFloat(componentValue) || 0;
        setPath(path, value);
    }

    function isSettingVisible(setting) {
        if (!setting.visibleWhen)
            return true;
        if (typeof setting.visibleWhen === "string")
            return !!getPath(setting.visibleWhen);
        if (setting.visibleWhen.length !== undefined) {
            for (var i = 0; i < setting.visibleWhen.length; i++) {
                if (!getPath(setting.visibleWhen[i]))
                    return false;
            }
            return true;
        }
        return true;
    }

    function stripLuaComments(text) {
        return String(text).replace(/--[^\n\r]*/g, "");
    }

    function findMatchingBrace(text, openIndex) {
        var depth = 0;
        var inString = false;
        var quote = "";
        for (var i = openIndex; i < text.length; i++) {
            var ch = text[i];
            var prev = i > 0 ? text[i - 1] : "";
            if (inString) {
                if (ch === quote && prev !== "\\")
                    inString = false;
                continue;
            }
            if (ch === '"' || ch === "'") {
                inString = true;
                quote = ch;
            } else if (ch === "{") {
                depth++;
            } else if (ch === "}") {
                depth--;
                if (depth === 0)
                    return i;
            }
        }
        return -1;
    }

    function parseLuaValue(text, state) {
        skipWhitespace(text, state);
        if (text[state.index] === "{") {
            var tableStart = state.index;
            var tableEnd = findMatchingBrace(text, tableStart);
            if (tableEnd >= 0) {
                var tableRaw = text.slice(tableStart, tableEnd + 1);
                if (tableRaw.indexOf("=") < 0) {
                    state.index = tableEnd + 1;
                    return tableRaw;
                }
            }
            state.index++;
            return parseLuaTable(text, state);
        }
        if (text[state.index] === '"' || text[state.index] === "'") {
            var quote = text[state.index++];
            var out = "";
            while (state.index < text.length) {
                var ch = text[state.index++];
                if (ch === quote)
                    break;
                out += ch;
            }
            return out;
        }
        var start = state.index;
        while (state.index < text.length && text[state.index] !== "," && text[state.index] !== "}")
            state.index++;
        var raw = text.slice(start, state.index).trim();
        if (raw === "true")
            return true;
        if (raw === "false")
            return false;
        if (raw === "nil")
            return "";
        if (/^-?\d+(\.\d+)?$/.test(raw))
            return parseFloat(raw);
        return raw;
    }

    function parseLuaTable(text, state) {
        var result = {};
        while (state.index < text.length) {
            skipWhitespaceAndCommas(text, state);
            if (text[state.index] === "}") {
                state.index++;
                break;
            }
            var keyStart = state.index;
            while (state.index < text.length && /[A-Za-z0-9_]/.test(text[state.index]))
                state.index++;
            var key = text.slice(keyStart, state.index).trim();
            skipWhitespace(text, state);
            if (!key || text[state.index] !== "=") {
                while (state.index < text.length && text[state.index] !== "," && text[state.index] !== "}")
                    state.index++;
                continue;
            }
            state.index++;
            result[key] = parseLuaValue(text, state);
            skipWhitespaceAndCommas(text, state);
        }
        return result;
    }

    function skipWhitespace(text, state) {
        while (state.index < text.length && /\s/.test(text[state.index]))
            state.index++;
    }

    function skipWhitespaceAndCommas(text, state) {
        while (state.index < text.length && (/\s/.test(text[state.index]) || text[state.index] === ","))
            state.index++;
    }

    function parseConfig(text) {
        var clean = stripLuaComments(text);
        var callIndex = clean.indexOf("hl.config");
        if (callIndex < 0)
            return clone(defaultValues);
        var openIndex = clean.indexOf("{", callIndex);
        if (openIndex < 0)
            return clone(defaultValues);
        var closeIndex = findMatchingBrace(clean, openIndex);
        if (closeIndex < 0)
            return clone(defaultValues);
        var state = {
            index: openIndex + 1
        };
        return mergeDefaults(parseLuaTable(clean, state));
    }

    function parseMonitorObject(tableValue) {
        if (!tableValue || !tableValue.output)
            return null;
        var item = {
            output: String(tableValue.output),
            mode: tableValue.mode !== undefined ? String(tableValue.mode) : "preferred",
            position: tableValue.position !== undefined ? String(tableValue.position) : "auto",
            scale: tableValue.scale !== undefined ? parseFloat(tableValue.scale) : 1,
            transform: tableValue.transform !== undefined ? parseInt(tableValue.transform) : 0
        };
        item.disabled = item.mode === "disable";
        var modeMatch = item.mode.match(/^(\d+)x(\d+)(?:@([\d.]+))?/);
        if (modeMatch) {
            item.width = parseInt(modeMatch[1]);
            item.height = parseInt(modeMatch[2]);
            item.refreshRate = modeMatch[3] !== undefined ? parseFloat(modeMatch[3]) : 60;
        }
        var posMatch = item.position.match(/^(-?\d+)x(-?\d+)$/);
        if (posMatch) {
            item.x = parseInt(posMatch[1]);
            item.y = parseInt(posMatch[2]);
        }
        return item;
    }

    function parseMonitorConfigs(text) {
        var clean = stripLuaComments(text);
        var items = [];
        var searchIndex = 0;
        while (searchIndex < clean.length) {
            var callIndex = clean.indexOf("hl.monitor", searchIndex);
            if (callIndex < 0)
                break;
            var openIndex = clean.indexOf("{", callIndex);
            if (openIndex < 0)
                break;
            var closeIndex = findMatchingBrace(clean, openIndex);
            if (closeIndex < 0)
                break;
            var state = {
                index: openIndex + 1
            };
            var item = parseMonitorObject(parseLuaTable(clean, state));
            if (item)
                items.push(item);
            searchIndex = closeIndex + 1;
        }
        return items;
    }

    function loadMonitorsFromText(text) {
        monitorItems = parseMonitorConfigs(text);
    }

    function monitorItemForOutput(output) {
        for (var i = 0; i < monitorItems.length; i++) {
            if (monitorItems[i].output === output)
                return monitorItems[i];
        }
        return null;
    }

    function applyMonitorConfigToMonitor(monitor, item) {
        if (!monitor || !item)
            return;
        monitor.disabled = !!item.disabled;
        if (item.width !== undefined)
            monitor.width = item.width;
        if (item.height !== undefined)
            monitor.height = item.height;
        if (item.refreshRate !== undefined)
            monitor.refreshRate = item.refreshRate;
        if (item.x !== undefined)
            monitor.x = item.x;
        if (item.y !== undefined)
            monitor.y = item.y;
        if (item.scale !== undefined && !isNaN(item.scale))
            monitor.scale = item.scale;
        if (item.transform !== undefined && !isNaN(item.transform))
            monitor.transform = item.transform;
    }

    function applyMonitorSettingsToList(monitorsList) {
        for (var i = 0; i < monitorsList.length; i++) {
            var monitor = monitorsList[i];
            applyMonitorConfigToMonitor(monitor, monitorItemForOutput(monitor.name));
        }
    }

    function monitorItemFromMonitor(monitor) {
        var disabled = !!monitor.disabled;
        return {
            output: monitor.name,
            description: monitor.description || "",
            mode: disabled ? "disable" : monitor.width + "x" + monitor.height + "@" + monitor.refreshRate,
            position: disabled ? "auto" : monitor.x + "x" + monitor.y,
            scale: monitor.scale !== undefined ? monitor.scale : 1,
            transform: monitor.transform !== undefined ? monitor.transform : 0,
            disabled: disabled,
            width: monitor.width,
            height: monitor.height,
            refreshRate: monitor.refreshRate,
            x: monitor.x,
            y: monitor.y
        };
    }

    function mergedMonitorItems(monitorsList) {
        var next = cloneList(monitorItems);
        for (var i = 0; i < monitorsList.length; i++) {
            var item = monitorItemFromMonitor(monitorsList[i]);
            var found = false;
            for (var j = 0; j < next.length; j++) {
                if (next[j].output === item.output) {
                    next[j] = item;
                    found = true;
                    break;
                }
            }
            if (!found)
                next.push(item);
        }
        return next;
    }

    function generateMonitorConfigContent(monitorsList) {
        var items = mergedMonitorItems(monitorsList);
        monitorItems = items;
        var config = "-- Monitor configuration generated by Quickshell::DisplaySettingsView\n";
        config += "-- Save path: ~/.config/hypr/monitors.lua\n";
        config += "-- Existing outputs are preserved and matching outputs are updated.\n\n";
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            if (item.description)
                config += "-- " + item.output + " - " + item.description + "\n";
            config += "hl.monitor({\n";
            config += "    output    = " + luaString(item.output) + ",\n";
            if (item.disabled) {
                config += "    mode      = \"disable\",\n";
            } else {
                config += "    mode      = " + luaString(item.mode || "preferred") + ",\n";
                config += "    position  = " + luaString(item.position || "auto") + ",\n";
                config += "    scale     = " + (item.scale !== undefined ? item.scale : 1) + ",\n";
                config += "    transform = " + (item.transform !== undefined ? item.transform : 0) + ",\n";
            }
            config += "})\n\n";
        }
        config += "-- Fallback for any unspecified monitors\n";
        config += "hl.monitor({\n";
        config += "    output   = \"\",\n";
        config += "    mode     = \"preferred\",\n";
        config += "    position = \"auto\",\n";
        config += "    scale    = 1,\n";
        config += "})\n";
        return config;
    }

    function parseMetadataList(text, key) {
        var prefix = "-- quickshell-" + key + ": ";
        var lines = String(text).split(/\n/);
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].indexOf(prefix) === 0) {
                try {
                    return JSON.parse(lines[i].slice(prefix.length));
                } catch (e) {
                    return [];
                }
            }
        }
        return [];
    }

    function formatLuaValue(value, type) {
        if (type === "bool")
            return value ? "true" : "false";
        if (type === "int" || type === "float")
            return String(value);
        if (type === "vector2") {
            var vector = normalizeValue("", value);
            if (!Array.isArray(value))
                vector = normalizeValue("decoration.shadow.offset", value);
            return "{ " + (parseFloat(vector[0]) || 0) + ", " + (parseFloat(vector[1]) || 0) + " }";
        }
        if (type === "raw")
            return String(value).trim();
        var escaped = String(value).replace(/\\/g, "\\\\").replace(/"/g, "\\\"");
        return '"' + escaped + '"';
    }

    function luaString(value) {
        return formatLuaValue(value || "", "string");
    }

    function cloneList(list) {
        return JSON.parse(JSON.stringify(list || []));
    }

    function getBindItems() {
        return bindItems;
    }

    function commonBindActionById(id) {
        for (var i = 0; i < commonBindActions.length; i++) {
            if (commonBindActions[i].id === id)
                return commonBindActions[i];
        }
        return commonBindActions[0];
    }

    function commonBindActionIndex(id) {
        for (var i = 0; i < commonBindActions.length; i++) {
            if (commonBindActions[i].id === id)
                return i;
        }
        return 0;
    }

    function bindParams(bind) {
        return bind && bind.params && typeof bind.params === "object" ? bind.params : inferBindParams(bind);
    }

    function bindParam(bind, key) {
        var params = bindParams(bind);
        var value = params[key];
        return value === undefined || value === null ? "" : String(value);
    }

    function inferBindAction(bind) {
        if (!bind)
            return "exec";
        if (bind.action)
            return bind.action;
        var dispatcher = String(bind.dispatcher || "");
        var argument = String(bind.argument || "");
        if (dispatcher === "exec" || dispatcher === "exec_cmd")
            return "exec";
        if (dispatcher === "global")
            return "global";
        if (argument.indexOf("hl.dsp.focus({ direction") === 0)
            return "focusDirection";
        if (argument.indexOf("hl.dsp.window.move({ direction") === 0)
            return "moveWindowDirection";
        if (argument.indexOf("hl.dsp.focus({ workspace") === 0)
            return "focusWorkspace";
        if (argument.indexOf("hl.dsp.window.move({ workspace") === 0)
            return "moveWindowWorkspace";
        if (argument.indexOf("hl.dsp.workspace.move") === 0)
            return "moveWorkspaceMonitor";
        if (argument.indexOf("hl.dispatch(hl.dsp.workspace.move") >= 0)
            return "grabWorkspace";
        if (argument === "hl.dsp.window.fullscreen()")
            return "fullscreen";
        if (argument.indexOf("hl.dsp.window.fullscreen_state") === 0)
            return "fullscreenState";
        if (argument === "hl.dsp.window.close()")
            return "closeWindow";
        if (argument.indexOf("hl.dsp.window.float") === 0)
            return "toggleFloating";
        if (argument === "hl.dsp.window.drag()")
            return "dragWindow";
        if (argument === "hl.dsp.window.resize()")
            return "resizeWindow";
        if (argument.indexOf("hl.dsp.layout") === 0)
            return "toggleSplit";
        if (argument.indexOf("general = { layout") >= 0)
            return "setLayout";
        if (argument === "hl.dsp.workspace.toggle_special()")
            return "toggleSpecialWorkspace";
        return "exec";
    }

    function firstMatch(text, regex, fallback) {
        var match = String(text || "").match(regex);
        if (!match)
            return fallback;
        for (var i = 1; i < match.length; i++) {
            if (match[i] !== undefined)
                return match[i];
        }
        return fallback;
    }

    function inferBindParams(bind) {
        var dispatcher = String(bind ? bind.dispatcher || "" : "");
        var argument = String(bind ? bind.argument || "" : "");
        var action = inferBindAction(bind);
        if (action === "exec")
            return { command: argument };
        if (action === "global")
            return { target: argument };
        if (action === "focusDirection" || action === "moveWindowDirection")
            return { direction: firstMatch(argument, /direction\s*=\s*\"([^\"]+)\"/, "l") };
        if (action === "focusWorkspace" || action === "moveWindowWorkspace")
            return { workspace: firstMatch(argument, /workspace\s*=\s*(?:\"([^\"]+)\"|(\d+))/, firstMatch(argument, /workspace\s*=\s*\d+/, "1")) };
        if (action === "moveWorkspaceMonitor")
            return { workspace: firstMatch(argument, /workspace\s*=\s*(?:\"([^\"]+)\"|(\d+))/, "special"), monitor: firstMatch(argument, /monitor\s*=\s*\"([^\"]+)\"/, "current") };
        if (action === "grabWorkspace")
            return { workspace: firstMatch(argument, /workspace\s*=\s*(\d+)/, "1") };
        if (action === "fullscreenState")
            return { internal: firstMatch(argument, /internal\s*=\s*(\d+)/, "0"), client: firstMatch(argument, /client\s*=\s*(\d+)/, "3") };
        if (action === "setLayout")
            return { layout: firstMatch(argument, /layout\s*=\s*\"([^\"]+)\"/, "dwindle") };
        return {};
    }

    function defaultParamsForAction(action) {
        if (action === "exec")
            return { command: "kitty" };
        if (action === "global")
            return { target: "quickshell:powermenu" };
        if (action === "focusDirection" || action === "moveWindowDirection")
            return { direction: "l" };
        if (action === "focusWorkspace" || action === "moveWindowWorkspace" || action === "grabWorkspace")
            return { workspace: "1" };
        if (action === "moveWorkspaceMonitor")
            return { workspace: "special", monitor: "current" };
        if (action === "fullscreenState")
            return { internal: "0", client: "3" };
        if (action === "setLayout")
            return { layout: "dwindle" };
        return {};
    }

    function setBindAction(index, action) {
        var next = cloneList(bindItems);
        if (!next[index])
            return;
        next[index].action = action;
        next[index].params = defaultParamsForAction(action);
        bindItems = next;
    }

    function setBindAdvanced(index, advanced) {
        var next = cloneList(bindItems);
        if (!next[index])
            return;
        next[index].advanced = advanced;
        bindItems = next;
    }

    function setBindParam(index, key, value) {
        var next = cloneList(bindItems);
        if (!next[index])
            return;
        var params = bindParams(next[index]);
        params[key] = value;
        next[index].params = params;
        bindItems = next;
    }

    function addBindItem() {
        var next = cloneList(bindItems);
        next.push({
            description: "Launch terminal",
            keys: "SUPER + Return",
            action: "exec",
            params: { command: "kitty" },
            dispatcher: "exec_cmd",
            argument: "kitty",
            flags: "",
            advanced: false
        });
        bindItems = next;
    }

    function removeBindItem(index) {
        var next = cloneList(bindItems);
        next.splice(index, 1);
        bindItems = next;
    }

    function updateBindItem(index, key, value) {
        var next = cloneList(bindItems);
        if (!next[index])
            return;
        next[index][key] = value;
        bindItems = next;
    }

    function keyName(key, text) {
        if (key >= Qt.Key_A && key <= Qt.Key_Z)
            return String.fromCharCode("A".charCodeAt(0) + key - Qt.Key_A);
        if (key >= Qt.Key_0 && key <= Qt.Key_9)
            return String.fromCharCode("0".charCodeAt(0) + key - Qt.Key_0);
        if (key >= Qt.Key_F1 && key <= Qt.Key_F35)
            return "F" + (key - Qt.Key_F1 + 1);
        if (key === Qt.Key_Return || key === Qt.Key_Enter)
            return "Return";
        if (key === Qt.Key_Escape)
            return "Escape";
        if (key === Qt.Key_Tab)
            return "Tab";
        if (key === Qt.Key_Backspace)
            return "Backspace";
        if (key === Qt.Key_Delete)
            return "Delete";
        if (key === Qt.Key_Insert)
            return "Insert";
        if (key === Qt.Key_Home)
            return "Home";
        if (key === Qt.Key_End)
            return "End";
        if (key === Qt.Key_PageUp)
            return "Page_Up";
        if (key === Qt.Key_PageDown)
            return "Page_Down";
        if (key === Qt.Key_Left)
            return "Left";
        if (key === Qt.Key_Right)
            return "Right";
        if (key === Qt.Key_Up)
            return "Up";
        if (key === Qt.Key_Down)
            return "Down";
        if (key === Qt.Key_Space)
            return "Space";
        if (key === Qt.Key_Minus)
            return "Minus";
        if (key === Qt.Key_Equal)
            return "Equal";
        if (key === Qt.Key_BracketLeft)
            return "BracketLeft";
        if (key === Qt.Key_BracketRight)
            return "BracketRight";
        if (key === Qt.Key_Backslash)
            return "Backslash";
        if (key === Qt.Key_Semicolon)
            return "Semicolon";
        if (key === Qt.Key_Apostrophe)
            return "Apostrophe";
        if (key === Qt.Key_Comma)
            return "Comma";
        if (key === Qt.Key_Period)
            return "Period";
        if (key === Qt.Key_Slash)
            return "Slash";
        if (key === Qt.Key_QuoteLeft)
            return "Grave";
        if (text && text.length === 1 && text.trim().length > 0)
            return text.toUpperCase();
        return "";
    }

    function getWindowRuleItems() {
        return windowRuleItems;
    }

    function addWindowRuleItem() {
        var next = cloneList(windowRuleItems);
        next.push({
            name: "New rule",
            matchClass: "",
            matchTitle: "",
            float: false,
            center: false,
            opaque: false,
            noBlur: false,
            noShadow: false,
            size: "",
            move: "",
            rounding: ""
        });
        windowRuleItems = next;
    }

    function removeWindowRuleItem(index) {
        var next = cloneList(windowRuleItems);
        next.splice(index, 1);
        windowRuleItems = next;
    }

    function updateWindowRuleItem(index, key, value) {
        var next = cloneList(windowRuleItems);
        if (!next[index])
            return;
        next[index][key] = value;
        windowRuleItems = next;
    }

    function bindFlagsArray(flagsText) {
        var flags = String(flagsText || "").split(",");
        var out = [];
        for (var i = 0; i < flags.length; i++) {
            var flag = flags[i].trim();
            if (flag.length > 0 && out.indexOf(flag) === -1)
                out.push(flag);
        }
        return out;
    }

    function bindHasFlag(bind, flag) {
        return bindFlagsArray(bind ? bind.flags : "").indexOf(flag) !== -1;
    }

    function setBindFlag(index, flag, enabled) {
        var next = cloneList(bindItems);
        if (!next[index])
            return;
        var flags = bindFlagsArray(next[index].flags);
        var flagIndex = flags.indexOf(flag);
        if (enabled && flagIndex === -1)
            flags.push(flag);
        if (!enabled && flagIndex !== -1)
            flags.splice(flagIndex, 1);
        next[index].flags = flags.join(", ");
        bindItems = next;
    }

    function luaFlags(flagsText) {
        var flags = bindFlagsArray(flagsText);
        var out = [];
        for (var i = 0; i < flags.length; i++) {
            out.push(flags[i] + " = true");
        }
        return out.length > 0 ? ", { " + out.join(", ") + " }" : "";
    }

    function luaBindOptions(bind) {
        var flags = bindFlagsArray(bind ? bind.flags : "");
        var out = [];
        for (var i = 0; i < flags.length; i++) {
            out.push(flags[i] + " = true");
        }
        var description = bind ? String(bind.description || bind.name || bind.comment || "").trim() : "";
        if (description.length > 0)
            out.push("description = " + luaString(description));
        return out.length > 0 ? ", { " + out.join(", ") + " }" : "";
    }

    function luaPairArray(value) {
        var parts = String(value || "").split(",");
        if (parts.length < 2)
            return "";
        return "{" + luaString(parts[0].trim()) + ", " + luaString(parts.slice(1).join(",").trim()) + "}";
    }

    function getLayerRuleItems() {
        return layerRuleItems;
    }

    function addLayerRuleItem() {
        var next = cloneList(layerRuleItems);
        next.push({
            name: "New layer rule",
            namespace: "",
            noAnim: false,
            blur: false,
            ignoreAlpha: "",
            xray: false
        });
        layerRuleItems = next;
    }

    function removeLayerRuleItem(index) {
        var next = cloneList(layerRuleItems);
        next.splice(index, 1);
        layerRuleItems = next;
    }

    function updateLayerRuleItem(index, key, value) {
        var next = cloneList(layerRuleItems);
        if (!next[index])
            return;
        next[index][key] = value;
        layerRuleItems = next;
    }

    function getAnimationItems() {
        return animationItems;
    }

    function addAnimationItem() {
        var next = cloneList(animationItems);
        next.push({
            leaf: "windows",
            enabled: true,
            speed: 4,
            bezier: "default",
            style: ""
        });
        animationItems = next;
    }

    function removeAnimationItem(index) {
        var next = cloneList(animationItems);
        next.splice(index, 1);
        animationItems = next;
    }

    function updateAnimationItem(index, key, value) {
        var next = cloneList(animationItems);
        if (!next[index])
            return;
        next[index][key] = value;
        animationItems = next;
    }

    function settingType(path) {
        for (var s = 0; s < sections.length; s++) {
            var settings = sections[s].settings;
            for (var i = 0; i < settings.length; i++) {
                if (settings[i].path === path)
                    return settings[i].type;
            }
        }
        return "string";
    }

    function setTreePath(tree, path, value) {
        var parts = path.split(".");
        var cursor = tree;
        for (var i = 0; i < parts.length - 1; i++) {
            if (!cursor[parts[i]])
                cursor[parts[i]] = {};
            cursor = cursor[parts[i]];
        }
        cursor[parts[parts.length - 1]] = value;
    }

    function buildConfigTree() {
        var tree = {};
        for (var s = 0; s < sections.length; s++) {
            var settings = sections[s].settings;
            mergeSettingsIntoTree(tree, settings);
        }
        return tree;
    }

    function buildConfigTreeForSection(sectionData) {
        var tree = {};
        mergeSettingsIntoTree(tree, sectionData.settings || []);
        return tree;
    }

    function mergeSettingsIntoTree(tree, settings) {
        for (var i = 0; i < settings.length; i++) {
            var setting = settings[i];
            var value = normalizeValue(setting.path, getPath(setting.path));
            var valueText = String(value === undefined || value === null ? "" : value).trim();
            if (setting.omitWhenEmpty && valueText === "")
                continue;
            if (setting.type === "raw" && valueText === "") {
                var defaultValue = getDefaultPath(setting.path);
                var defaultText = String(defaultValue === undefined || defaultValue === null ? "" : defaultValue).trim();
                if (defaultText === "")
                    continue;
                value = defaultValue;
            }
            setTreePath(tree, setting.path, value);
        }
    }

    function objectIsEmpty(obj) {
        return Object.keys(obj).length === 0;
    }

    function sectionFileName(sectionData) {
        var title = String(sectionData.title).toLowerCase();
        var out = "";
        var lastWasDash = false;
        for (var i = 0; i < title.length; i++) {
            var ch = title[i];
            var valid = (ch >= "a" && ch <= "z") || (ch >= "0" && ch <= "9");
            if (valid) {
                out += ch;
                lastWasDash = false;
            } else if (!lastWasDash && out.length > 0) {
                out += "-";
                lastWasDash = true;
            }
        }
        if (out[out.length - 1] === "-")
            out = out.slice(0, out.length - 1);
        return out + ".lua";
    }

    function sectionFilePath(sectionData) {
        return configDir + "/" + sectionFileName(sectionData);
    }

    function luaKey(key) {
        if (/^[A-Za-z_][A-Za-z0-9_]*$/.test(key))
            return key;
        return "[" + luaString(key) + "]";
    }

    function luaTableForObject(mapValue, indent, pathPrefix) {
        var config = "{";
        config += String.fromCharCode(10);
        var keys = Object.keys(mapValue);
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            var value = mapValue[key];
            var childPath = pathPrefix ? pathPrefix + "." + key : key;
            var renderedKey = luaKey(key);
            if (value !== null && typeof value === "object" && !Array.isArray(value)) {
                config += indent + "    " + renderedKey + " = " + luaTableForObject(value, indent + "    ", childPath) + ",\n";
            } else {
                config += indent + "    " + renderedKey + " = " + formatLuaValue(value, settingType(childPath)) + ",\n";
            }
        }
        config += indent + "}";
        return config;
    }

    function workspaceLuaValue(value) {
        var text = String(value || "").trim();
        return /^-?\d+$/.test(text) ? text : luaString(text);
    }

    function commonBindExpression(bind) {
        var action = inferBindAction(bind);
        var params = bindParams(bind);
        if (action === "exec")
            return "hl.dsp.exec_cmd(" + luaString(params.command || "") + ")";
        if (action === "global")
            return "hl.dsp.global(" + luaString(params.target || "") + ")";
        if (action === "focusDirection")
            return "hl.dsp.focus({ direction = " + luaString(params.direction || "l") + " })";
        if (action === "moveWindowDirection")
            return "hl.dsp.window.move({ direction = " + luaString(params.direction || "l") + " })";
        if (action === "focusWorkspace")
            return "hl.dsp.focus({ workspace = " + workspaceLuaValue(params.workspace || "1") + " })";
        if (action === "moveWindowWorkspace")
            return "hl.dsp.window.move({ workspace = " + workspaceLuaValue(params.workspace || "1") + " })";
        if (action === "moveWorkspaceMonitor")
            return "hl.dsp.workspace.move({ workspace = " + workspaceLuaValue(params.workspace || "special") + ", monitor = " + luaString(params.monitor || "current") + " })";
        if (action === "grabWorkspace") {
            var workspace = workspaceLuaValue(params.workspace || "1");
            return "function()\n    hl.dispatch(hl.dsp.workspace.move({ workspace = " + workspace + ", monitor = \"current\" }))\n    hl.dispatch(hl.dsp.focus({ workspace = " + workspace + " }))\nend";
        }
        if (action === "fullscreen")
            return "hl.dsp.window.fullscreen()";
        if (action === "fullscreenState")
            return "hl.dsp.window.fullscreen_state({ internal = " + (parseInt(params.internal) || 0) + ", client = " + (parseInt(params.client) || 0) + " })";
        if (action === "closeWindow")
            return "hl.dsp.window.close()";
        if (action === "toggleFloating")
            return "hl.dsp.window.float({ action = \"toggle\" })";
        if (action === "dragWindow")
            return "hl.dsp.window.drag()";
        if (action === "resizeWindow")
            return "hl.dsp.window.resize()";
        if (action === "toggleSplit")
            return "hl.dsp.layout(\"togglesplit\")";
        if (action === "setLayout")
            return "function()\n    hl.config({ general = { layout = " + luaString(params.layout || "dwindle") + " } })\nend";
        if (action === "toggleSpecialWorkspace")
            return "hl.dsp.workspace.toggle_special()";
        return "";
    }

    function advancedBindExpression(bind) {
        var dispatcher = String(bind.dispatcher || "exec_cmd");
        var argument = String(bind.argument || "");
        if (dispatcher === "raw" || dispatcher === "callback")
            return argument;
        if (dispatcher === "exec")
            dispatcher = "exec_cmd";
        return "hl.dsp." + dispatcher + "(" + luaString(argument) + ")";
    }

    function generateBindConfig() {
        var config = "";
        for (var i = 0; i < bindItems.length; i++) {
            var bind = bindItems[i];
            if (bind.rawLine) {
                config += String(bind.rawLine).trim() + "\n";
                continue;
            }
            if (!bind.keys)
                continue;
            var dsp = bind.advanced ? advancedBindExpression(bind) : commonBindExpression(bind);
            if (!dsp)
                dsp = advancedBindExpression(bind);
            if (!dsp)
                continue;
            config += "hl.bind(" + luaString(bind.keys) + ", " + dsp + luaBindOptions(bind) + ")\n";
        }
        return config;
    }

    function generateWindowRuleConfig() {
        var config = "";
        for (var i = 0; i < windowRuleItems.length; i++) {
            var rule = windowRuleItems[i];
            if (!rule.name && !rule.matchClass && !rule.matchTitle)
                continue;
            config += "hl.window_rule({\n";
            if (rule.name)
                config += "    name = " + luaString(rule.name) + ",\n";
            config += "    match = {";
            var matchParts = [];
            if (rule.matchClass)
                matchParts.push("class = " + luaString(rule.matchClass));
            if (rule.matchTitle)
                matchParts.push("title = " + luaString(rule.matchTitle));
            config += matchParts.length > 0 ? " " + matchParts.join(", ") + " " : "";
            config += "},\n";
            if (rule.float)
                config += "    float = true,\n";
            if (rule.center)
                config += "    center = true,\n";
            if (rule.opaque)
                config += "    opaque = true,\n";
            if (rule.noBlur)
                config += "    no_blur = true,\n";
            if (rule.noShadow)
                config += "    no_shadow = true,\n";
            var size = luaPairArray(rule.size);
            if (size)
                config += "    size = " + size + ",\n";
            var move = luaPairArray(rule.move);
            if (move)
                config += "    move = " + move + ",\n";
            if (String(rule.rounding || "").trim() !== "")
                config += "    rounding = " + parseInt(rule.rounding) + ",\n";
            config += "})\n\n";
        }
        return config;
    }

    function generateLayerRuleConfig() {
        var config = "";
        for (var i = 0; i < layerRuleItems.length; i++) {
            var rule = layerRuleItems[i];
            if (!rule.name && !rule.namespace)
                continue;
            config += "hl.layer_rule({\n";
            if (rule.name)
                config += "    name = " + luaString(rule.name) + ",\n";
            config += "    match = {" + (rule.namespace ? " namespace = " + luaString(rule.namespace) + " " : "") + "},\n";
            if (rule.noAnim)
                config += "    no_anim = true,\n";
            if (rule.blur)
                config += "    blur = true,\n";
            if (rule.xray)
                config += "    xray = true,\n";
            if (String(rule.ignoreAlpha || "").trim() !== "")
                config += "    ignorealpha = " + parseFloat(rule.ignoreAlpha) + ",\n";
            config += "})\n\n";
        }
        return config;
    }

    function generateAnimationConfig() {
        var config = "";
        for (var i = 0; i < animationItems.length; i++) {
            var anim = animationItems[i];
            if (!anim.leaf)
                continue;
            config += "hl.animation({ leaf = " + luaString(anim.leaf);
            config += ", enabled = " + (!!anim.enabled ? "true" : "false");
            config += ", speed = " + (parseFloat(anim.speed) || 0);
            if (anim.bezier)
                config += ", bezier = " + luaString(anim.bezier);
            if (anim.style)
                config += ", style = " + luaString(anim.style);
            config += " })\n";
        }
        return config;
    }

    function metadataHeader() {
        var config = "-- quickshell-values: " + JSON.stringify(values) + "\n";
        config += "-- quickshell-bind-items: " + JSON.stringify(bindItems) + "\n";
        config += "-- quickshell-window-rule-items: " + JSON.stringify(windowRuleItems) + "\n";
        config += "-- quickshell-layer-rule-items: " + JSON.stringify(layerRuleItems) + "\n";
        config += "-- quickshell-animation-items: " + JSON.stringify(animationItems) + "\n";
        return config;
    }

    function generateSectionConfig(sectionData) {
        var config = "-- Hyprland " + sectionData.title + " generated by Quickshell::HyprlandSettingsView\n";
        config += "-- Source variables: https://wiki.hypr.land/Configuring/Basics/Variables/\n";
        config += "-- Save path: ~/.config/hypr/quickshell/" + sectionFileName(sectionData) + "\n\n";

        if (sectionData.kind === "bindList") {
            config += "-- quickshell-bind-items: " + JSON.stringify(bindItems) + "\n\n";
            var bindConfig = generateBindConfig();
            return config + (bindConfig.length > 0 ? bindConfig : "-- No generated keybinds yet.\n");
        }
        if (sectionData.kind === "windowRuleList") {
            config += "-- quickshell-window-rule-items: " + JSON.stringify(windowRuleItems) + "\n\n";
            var ruleConfig = generateWindowRuleConfig();
            return config + (ruleConfig.length > 0 ? ruleConfig : "-- No generated window rules yet.\n");
        }
        if (sectionData.kind === "layerRuleList") {
            config += "-- quickshell-layer-rule-items: " + JSON.stringify(layerRuleItems) + "\n\n";
            var layerRuleConfig = generateLayerRuleConfig();
            return config + (layerRuleConfig.length > 0 ? layerRuleConfig : "-- No generated layer rules yet.\n");
        }
        if (sectionData.kind === "animationList") {
            config += "-- quickshell-animation-items: " + JSON.stringify(animationItems) + "\n\n";
            var animationConfig = generateAnimationConfig();
            return config + (animationConfig.length > 0 ? animationConfig : "-- No generated animations yet.\n");
        }

        var tree = buildConfigTreeForSection(sectionData);
        if (objectIsEmpty(tree))
            return config + "-- No hl.config settings for this tab.\n";
        return config + "hl.config(" + luaTableForObject(tree, "", "") + ")\n";
    }

    function moduleNameForSection(sectionData) {
        var fileName = sectionFileName(sectionData);
        return "quickshell." + fileName.slice(0, fileName.length - 4);
    }

    function generateConfig() {
        var config = "-- Hyprland Quickshell settings init generated by Quickshell::HyprlandSettingsView\n";
        config += "-- Save path: ~/.config/hypr/quickshell/init.lua\n";
        config += "-- This file intentionally only stores SettingsMenu metadata and imports per-tab files.\n";
        config += "-- The actual Hyprland Lua is written to the sibling files in this directory.\n";
        config += metadataHeader() + "\n";
        for (var i = 0; i < sections.length; i++) {
            var section = sections[i];
            config += "require(" + luaString(moduleNameForSection(section)) + ")\n";
        }
        return config;
    }

    function parseMetadataObject(text, key) {
        var prefix = "-- quickshell-" + key + ": ";
        var lines = String(text).split(/\n/);
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].indexOf(prefix) === 0) {
                try {
                    return JSON.parse(lines[i].slice(prefix.length));
                } catch (e) {
                    return null;
                }
            }
        }
        return null;
    }

    function loadFromText(text) {
        var storedValues = parseMetadataObject(text, "values");
        values = storedValues ? mergeDefaults(storedValues) : parseConfig(text);
        bindItems = parseMetadataList(text, "bind-items");
        windowRuleItems = parseMetadataList(text, "window-rule-items");
        layerRuleItems = parseMetadataList(text, "layer-rule-items");
        animationItems = parseMetadataList(text, "animation-items");
    }
}
