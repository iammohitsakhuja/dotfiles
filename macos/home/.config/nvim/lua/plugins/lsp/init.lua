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
                    border = "rounded",
                    source = true,
                    header = "",
                    prefix = "",
                },
            })

            -- Configure LSP floating windows with borders (Neovim 0.11+ approach)
            local _hover = vim.lsp.buf.hover
            vim.lsp.buf.hover = function(opts)
                opts = opts or {}
                opts.border = opts.border or 'rounded'
                return _hover(opts)
            end

            local _signature_help = vim.lsp.buf.signature_help
            vim.lsp.buf.signature_help = function(opts)
                opts = opts or {}
                opts.border = opts.border or 'rounded'
                return _signature_help(opts)
            end

            local _open_floating_preview = vim.lsp.util.open_floating_preview
            vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = opts.border or 'rounded' -- or whichever border kind you want
                return _open_floating_preview(contents, syntax, opts, ...)
            end

            -- LspAttach autocmd for additional keymaps not covered by defaults
            vim.api.nvim_create_autocmd("LspAttach", {
                desc = "LSP actions",
                callback = function(event)
                    local opts = { buffer = event.buf, noremap = true, silent = true }

                    -- Essential keymaps missing from Neovim 0.11 defaults
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

                    -- Note: LSP completion is handled by blink.cmp via capabilities.
                    -- It even reports the capabilities on its own.
                    -- Hence, no need to enable native LSP completion.
                end,
            })

            -- Manually enable Dart LS since it's not available via Mason.
            vim.lsp.enable("dartls")
        end,
    },

    -- Fidget for better notifications for the LSP.
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
