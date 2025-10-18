---@module "lazy"
---@type LazySpec
return {
    "folke/which-key.nvim",
    -- Lazy loading the plugin does not work: https://github.com/folke/which-key.nvim/issues/981
    -- So we just defer it with VeryLazy.
    event = "VeryLazy",
    opts = {
        preset = "classic",
        plugins = {
            marks = false,
            registers = false,
        },
        win = {
            border = "rounded", -- We need this even if we set `winborder` globally via `vim.opt`
        },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}
