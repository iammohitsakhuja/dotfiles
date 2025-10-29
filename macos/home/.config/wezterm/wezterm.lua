-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Font settings
config.font = wezterm.font_with_fallback({
    { family = "Cascadia Code" },
    {
        family = "Monaspace Argon",
        -- Enable Monaspace Texture Healing and Coding Ligatures
        harfbuzz_features = { "calt", "liga", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08", "ss09" },
    },
    { family = "Symbols Nerd Font" },
})
config.font_size = 15

-- Appearance
local color_scheme = "Catppuccin Mocha"
local base = wezterm.color.get_builtin_schemes()[color_scheme]

config.color_scheme = color_scheme -- Provide base color scheme.
config.colors = base -- Explicitly ensure colors are applied in all elements of the terminal.

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false -- Since we can't theme it.

config.window_frame = {
    font = wezterm.font({ family = "Cascadia Code", weight = "Bold" }),
    font_size = 13,
    active_titlebar_bg = base.cursor_fg,
    active_titlebar_fg = base.foreground,
    inactive_titlebar_bg = base.cursor_fg,
    inactive_titlebar_fg = base.foreground,
    button_bg = base.cursor_fg,
    button_fg = base.foreground,
}

-- Command Palette
config.command_palette_bg_color = base.cursor_fg
config.command_palette_fg_color = base.foreground
config.command_palette_font = wezterm.font({ family = "Cascadia Code" })
config.command_palette_font_size = 15

-- Miscellaneous
config.front_end = "WebGpu" -- Use Metal/Vulkan/DX12 rather than OpenGL.
config.max_fps = 120
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.initial_cols = 150 -- Useful when not using a TWM
config.initial_rows = 45

-- Keymappings.
config.keys = {
    -- Useful for TUIs, such as Claude Code.
    { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
}

return config
