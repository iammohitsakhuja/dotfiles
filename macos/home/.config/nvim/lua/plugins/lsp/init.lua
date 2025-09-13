return {
    -- LSP Configuration for Neovim Lua files
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        cmd = "LazyDev",
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- Mason: Package manager for LSP servers, DAP servers, linters, and formatters
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        },
    },

    -- Mason-LSPConfig: Bridge between mason.nvim and nvim-lspconfig
    -- Combined configuration for Mason-LSPConfig & Nvim-LSPConfig to ensure plugin order
    -- Also includes LSP Diagnostic and Keymap configuration.
    {
        "mason-org/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
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
                        [vim.diagnostic.severity.INFO] = ""
                    },
                    -- Color line numbers based on diagnostic severity
                    numhl = {
                        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
                        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo"
                    }
                },
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = {
                    source = true,
                    header = "",
                    prefix = "",
                },
            })

            -- Manually enable Dart LS since it's not available via Mason.
            vim.lsp.enable("dartls")

            -- Setup Mason-LSPConfig while auto-enabling certain servers
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "bashls",
                    "clangd",
                    "cssls",
                    "dockerls",
                    "gopls",
                    "helm_ls",
                    "html",
                    "jdtls",
                    "jsonls",
                    "lua_ls",
                    "marksman",
                    "protols",
                    "pyright",
                    "rust_analyzer",
                    "sqlls",
                    "ts_ls",
                    "vimls",
                    "yamlls",
                },
                automatic_enable = true,
            })
        end,
    },

    -- Fidget for better notifications for the LSP.
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
