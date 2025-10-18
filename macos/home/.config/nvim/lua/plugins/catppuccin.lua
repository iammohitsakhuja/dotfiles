---@module "lazy"
---@type LazySpec
return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    ---@module "catppuccin"
    ---@type CatppuccinOptions
    opts = {
        auto_integrations = true,
        integrations = {
            indent_blankline = {
                enabled = true,
                scope_color = "lavender",
                colored_indent_levels = false,
            },
        },
        background = {
            light = "latte",
            dark = "mocha",
        },
        flavour = "auto",
        float = {
            transparent = true,
            solid = false,
        },
        term_colors = true,
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}
