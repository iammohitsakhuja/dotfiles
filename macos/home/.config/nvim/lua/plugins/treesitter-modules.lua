---@module "lazy"
---@type LazySpec
return {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
    opts = {
        -- Just install all parsers, they take up ~300MB storage space. Not worth the headache of loading them on-demand.
        ensure_installed = "all",
        auto_install = true,
        fold = { enable = false }, -- Disabled in favor of nvim-ufo
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "gss",
                node_incremental = "gni",
                scope_incremental = "gsi",
                node_decremental = "gnd",
            },
        },
    },
}
