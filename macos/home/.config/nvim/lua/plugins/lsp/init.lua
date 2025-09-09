return {
    -- LSP Configuration for Neovim Lua files
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
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
                border = "rounded",
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
    {
        "mason-org/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
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

            -- Custom server configurations using vim.lsp.config()
            -- Clangd (C/C++)
            vim.lsp.config("clangd", {
                cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
            })

            -- Gopls (Go)
            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                        },
                        staticcheck = true,
                        gofumpt = true,
                    },
                },
            })

            -- Java (jdtls)
            vim.lsp.config("jdtls", {
                settings = {
                    java = {
                        signatureHelp = { enabled = true },
                        completion = { enabled = true },
                        sources = {
                            organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
                        },
                        symbols = {
                            includeSourceMethodDeclarations = true,
                        },
                    },
                },
            })

            -- Lua
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim", "require" } },
                        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                        telemetry = { enable = false },
                    },
                },
            })

            -- Python (pyright)
            vim.lsp.config("pyright", {
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "workspace",
                        },
                    },
                },
            })

            -- YAML
            vim.lsp.config("yamlls", {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                            ["https://json.schemastore.org/github-action.json"] = "/action.yml",
                        },
                    },
                },
            })

            -- Manually enable Dart LS since it's not available via Mason.
            vim.lsp.enable("dartls")

        end,
    },
}
