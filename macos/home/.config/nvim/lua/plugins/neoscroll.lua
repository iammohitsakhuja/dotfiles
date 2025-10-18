---@module "lazy"
---@type LazySpec
return {
    "karb94/neoscroll.nvim",
    -- Skip lazy loading to avoid issues with different Neovim entry modes.
    -- Plugin is lightweight, so we load it without performance concerns but still defer with VeryLazy.
    event = "VeryLazy",
    opts = {
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = false,
        stop_eof = true,
        respect_scrolloff = true,
        cursor_scrolls_alone = true,
    },
}
