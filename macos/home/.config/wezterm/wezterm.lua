-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Font settings
config.font_size = 15
config.font = wezterm.font_with_fallback({
    {
        family = "Monaspace Argon",
        -- Enable Monaspace Texture Healing and Coding Ligatures
        harfbuzz_features = { "calt", "liga", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08", "ss09" },
    },
    { family = "Symbols Nerd Font" },
})

config.color_scheme = "Catppuccin Mocha"

-- Window decoration settings
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_padding = {
    right = 0,
    left = 4,
}

-- WezTerm tabbar settings
config.window_frame = {
    font = wezterm.font({ family = "Monaspace Argon", weight = "Bold" }),
    font_size = 14,
    active_titlebar_bg = "#13151f",
}

config.colors = {
    tab_bar = {
        active_tab = {
            bg_color = "#1e1e2e",
            fg_color = "#ffffff",
        },
    },
}

config.audible_bell = "Disabled"

return config
