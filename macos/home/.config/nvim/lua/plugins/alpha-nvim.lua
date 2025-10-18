---@module "lazy"
---@type LazySpec
return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
            "                                                     ",
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
            "                                                     ",
        }

        dashboard.section.buttons.val = {
            dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
            dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
            dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
            dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
            dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua<CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
        }

        alpha.setup(dashboard.config)
    end,
}
