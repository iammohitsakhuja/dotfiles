---@module "lazy"
---@type LazySpec
return {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = {
        "mason-org/mason.nvim",
        "folke/lazydev.nvim",
        "saghen/blink.cmp", -- Make sure `blink.cmp` is present before setting up more configs.
        "neovim/nvim-lspconfig",
    },
    opts = {
        ensure_installed = {
            "bashls",
            "basedpyright",
            "cssls",
            "docker_language_server",
            "gopls",
            "helm_ls",
            "html",
            "intelephense",
            "jdtls",
            "jsonls",
            "lua_ls",
            "marksman",
            "protols",
            "rust_analyzer",
            "ts_ls",
            "yamlls",
        },
        automatic_enable = {
            -- NOTE: By default, Mason will auto-enable any servers installed via `ensure_installed`.
            -- In order to exclude specific ones, we can do so here.
            exclude = {},
        },
    },
}
