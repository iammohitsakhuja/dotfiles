---@module "lazy"
---@type LazySpec
return {
    "folke/which-key.nvim",
    -- Lazy loading the plugin does not work: https://github.com/folke/which-key.nvim/issues/981
    -- So we just defer it with VeryLazy.
    event = "VeryLazy",
    ---@module "which-key.config"
    ---@type wk.Opts
    opts = {
        preset = "modern",
        plugins = {
            marks = false,
            registers = false,
        },
        win = {
            border = "rounded", -- We need this even if we set `winborder` globally via `vim.opt`
        },
        spec = {
            { "<leader>b", group = "Buffer" },
            { "<leader>c", group = "Conform or Trouble" },
            { "<leader>d", group = "Debug" },
            { "<leader>du", group = "Debug UI" },
            { "<leader>e", group = "Explorer (Nvim Tree)" },
            { "<leader>f", group = "Telescope" },
            { "<leader>h", group = "Git" },
            { "<leader>s", group = "Session or Treesitter Swap" },
            { "<leader>t", group = "Toggle" },
            { "<leader>x", group = "Trouble" },
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
