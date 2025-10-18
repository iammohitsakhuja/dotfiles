---@module "lazy"
---@type LazySpec
return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
        "folke/lazydev.nvim",
        "saghen/blink.cmp", -- Make sure `blink.cmp` is present before setting up more configs.
    },
    config = function()
        -- Configure diagnostics
        vim.diagnostic.config({
            virtual_text = {
                prefix = "●",
                spacing = 2,
            },
            signs = {
                -- Use empty strings to hide sign text, keeping only colored line numbers
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "",
                },
                -- Color line numbers based on diagnostic severity
                numhl = {
                    [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                    [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                    [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
                    [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
                },
            },
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                focusable = false,
                source = true,
                header = "",
                prefix = "",
            },
        })

        -- Enable LSP servers that are not covered by Mason.
        vim.lsp.enable("dartls")
    end,
}
