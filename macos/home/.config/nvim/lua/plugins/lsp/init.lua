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

    -- LSP Configuration and Diagnostics
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        dependencies = {
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
                    focusable = false,
                    source = true,
                    header = "",
                    prefix = "",
                },
            })

            -- Enable LSP servers
            vim.lsp.enable("bashls")
            vim.lsp.enable("basedpyright")
            vim.lsp.enable("cssls")
            vim.lsp.enable("dartls")
            vim.lsp.enable("docker_language_server")
            vim.lsp.enable("gopls")
            vim.lsp.enable("helm_ls")
            vim.lsp.enable("html")
            vim.lsp.enable("jdtls")
            vim.lsp.enable("jsonls")
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("marksman")
            vim.lsp.enable("protols")
            vim.lsp.enable("rust_analyzer")
            vim.lsp.enable("ts_ls")
            vim.lsp.enable("yamlls")
        end,
    },

    -- Fidget for better notifications for the LSP.
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        opts = {
            ---@module "fidget.notification"
            ---@type Config
            notification = {
                window = {
                    winblend = 0,
                },
            },
        },
    },
}
