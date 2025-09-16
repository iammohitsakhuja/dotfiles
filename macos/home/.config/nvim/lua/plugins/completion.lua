return {
    -- Better looking completion menu
    { "xzbdmw/colorful-menu.nvim", opts = {} },

    -- blink.cmp: Modern completion engine with Rust-based fuzzy matching
    {
        "saghen/blink.cmp",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "onsails/lspkind.nvim",
            "xzbdmw/colorful-menu.nvim",
        },
        version = "1.6.0",
        -- Important to initialize it before `InsertEnter` so that Neovim doesn't report incorrect capabilities to the LSP server.
        event = "VeryLazy",
        ---@module "blink.cmp"
        ---@type blink.cmp.Config
        opts = {
            -- Use default keymap preset (Ctrl+Y to accept completion)
            keymap = {
                preset = "default",
                ["<A-1>"] = { function(cmp) cmp.accept({ index = 1 }) end },
                ["<A-2>"] = { function(cmp) cmp.accept({ index = 2 }) end },
                ["<A-3>"] = { function(cmp) cmp.accept({ index = 3 }) end },
                ["<A-4>"] = { function(cmp) cmp.accept({ index = 4 }) end },
                ["<A-5>"] = { function(cmp) cmp.accept({ index = 5 }) end },
                ["<A-6>"] = { function(cmp) cmp.accept({ index = 6 }) end },
                ["<A-7>"] = { function(cmp) cmp.accept({ index = 7 }) end },
                ["<A-8>"] = { function(cmp) cmp.accept({ index = 8 }) end },
                ["<A-9>"] = { function(cmp) cmp.accept({ index = 9 }) end },
                ["<A-0>"] = { function(cmp) cmp.accept({ index = 10 }) end },
            },

            appearance = {
                -- `mono` allows spacing to ensure icons are aligned.
                nerd_font_variant = "mono",
            },

            -- Completion menu configuration
            completion = {
                keyword = {
                    -- Match full keywords rather than just prefixes.
                    range = "full",
                },

                menu = {
                    max_height = 12, -- Actual max no. of completion items is 2 less than this.
                    draw = {
                        gap = 2, -- Column gap
                        columns = {
                            { "item_idx" },
                            { "label" },
                            { "kind_icon", "kind", gap = 1 } -- Component gap
                        },
                        components = {
                            item_idx = {
                                text = function(ctx) return tostring(ctx.idx) end,
                                highlight = "BlinkCmpItemIdx"
                            },

                            label = {
                                text = function(ctx)
                                    return require("colorful-menu").blink_components_text(ctx)
                                end,
                                highlight = function(ctx)
                                    return require("colorful-menu").blink_components_highlight(ctx)
                                end,
                            },

                            kind_icon = {
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    else
                                        icon = require("lspkind").symbolic(ctx.kind, {
                                            mode = "symbol",
                                        })
                                    end

                                    return icon .. ctx.icon_gap
                                end,

                                highlight = function(ctx)
                                    local hl = ctx.kind_hl
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            hl = dev_hl
                                        end
                                    end
                                    return hl
                                end,
                            },

                            kind = {
                                highlight = function(ctx)
                                    local hl = "BlinkCmpKind" .. ctx.kind
                                    or require("blink.cmp.completion.windows.render.tailwind").get_hl(ctx)
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            hl = dev_hl
                                        end
                                    end
                                    return hl
                                end,
                            }
                        },

                        -- TODO: Check if this is still required if we are using `colorful-menu`.
                        treesitter = { "lsp" },
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },

                list = {
                    selection = {
                        preselect = true,
                        auto_insert = false,
                    },
                },
            },

            -- Default sources: LSP, path, snippets, buffer (with keyword length limit)
            sources = {
                -- Dynamically pick providers by treesitter node/filetype.
                default = function()
                    local success, node = pcall(vim.treesitter.get_node)
                    if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
                        return { "buffer" }
                    elseif vim.bo.filetype == "lua" then
                        return { "lazydev", "lsp", "path" }
                    else
                        return { "lsp", "path", "snippets", "buffer" }
                    end
                end,
                providers = {
                    buffer = {
                        min_keyword_length = 3, -- Only trigger buffer completion after 3+ characters
                    },

                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },

                    -- Get path completion from `cwd` instead of current buffer"s directory.
                    path = {
                        opts = {
                            get_cwd = function(_)
                                return vim.fn.getcwd()
                            end,
                        },
                    },
                },
            },

            -- Use Rust-based fuzzy matching for performance
            fuzzy = {
                implementation = "prefer_rust_with_warning",
                sorts = {
                    -- Always prioritize exact matches first.
                    'exact',
                    'score',
                    'sort_text',
                },
            },

            -- Enable experimental signature help support.
            signature = {
                enabled = true,
            },
        },
    },
}
