---@module "lazy"
---@type LazySpec
return {
    -- Colorschemes
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        ---@type CatppuccinOptions
        opts = {
            auto_integrations = true,
            integrations = {
                indent_blankline = {
                    enabled = true,
                    scope_color = "lavender",
                    colored_indent_levels = false,
                },
            },
            background = {
                light = "latte",
                dark = "macchiato",
            },
            flavour = "auto",
            float = {
                transparent = true,
                solid = false,
            },
            term_colors = true,
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "auto",
                globalstatus = true, -- Have a single statusline instead of one per each split
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { "buffers" },
                lualine_x = { "lsp_status", "encoding", "fileformat", "filetype" },
                lualine_y = { "progress", "searchcount", "selectioncount" },
                lualine_z = { "location" },
            },
        },
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            sort_by = "name",
            view = {
                width = 50,
                side = "left",
            },
            renderer = {
                group_empty = true,
                highlight_git = true,
                icons = {
                    show = {
                        git = true,
                    },
                },
            },
            filters = {
                dotfiles = false,
                custom = { ".DS_Store", ".git", "node_modules", "vendor", "build" },
            },
            git = {
                enable = true,
                ignore = false,
            },
            actions = {
                open_file = {
                    quit_on_open = false,
                },
            },
        },
    },

    -- Dashboard
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                "                                                     ",
            }

            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
                dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
                dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
                dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
                dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua<CR>"),
                dashboard.button("q", "  Quit", ":qa<CR>"),
            }

            alpha.setup(dashboard.config)
        end,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        ---@module "ibl"
        ---@type ibl.config
        opts = {
            indent = {
                char = "│",
                tab_char = "│",
            },
            scope = {
                enabled = true,
            },
            exclude = {
                filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "notify" },
            },
        },
    },

    -- Virtual Column
    {
        "lukas-reineke/virt-column.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            virtcolumn = "+1,120" -- Highlight the 1st column after 120 columns.
        }
    },

    -- Smooth scrolling
    {
        "karb94/neoscroll.nvim",
        -- Skip lazy loading to avoid issues with different Neovim entry modes.
        -- Plugin is lightweight, so we load it without performance concerns but still defer with VeryLazy.
        event = "VeryLazy",
        opts = {
            mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
            hide_cursor = false,
            stop_eof = true,
            respect_scrolloff = true,
            cursor_scrolls_alone = true,
        }
    },

    -- Buffer line
    {
        "akinsho/bufferline.nvim",
        version = "*",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "catppuccin", "nvim-tree/nvim-web-devicons" },
        ---@module "bufferline"
        ---@type bufferline.UserConfig
        opts = {
            options = {
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(count, level)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        highlight = "Directory",
                        text_align = "center",
                        separator = true,
                    },
                },
                get_element_icon = function(element)
                    local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype,
                        { default = false })
                    return icon, hl
                end,
                sort_by = "insert_after_current",
            },
        },
        config = function(_, opts)
            if (vim.g.colors_name or ""):find("catppuccin") then
                opts.highlights = require("catppuccin.groups.integrations.bufferline").get_theme()
            end

            require("bufferline").setup(opts)

            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
                callback = function()
                    vim.schedule(function()
                        pcall(nvim_bufferline)
                    end)
                end,
            })
        end,
        keys = {
            { "[b",          "<cmd>BufferLineCyclePrev<cr>",   desc = "Prev Buffer" },
            { "]b",          "<cmd>BufferLineCycleNext<cr>",   desc = "Next Buffer" },
            { "[B",          "<cmd>BufferLineMovePrev<cr>",    desc = "Move buffer prev" },
            { "]B",          "<cmd>BufferLineMoveNext<cr>",    desc = "Move buffer next" },
            { "<leader>bp",  "<Cmd>BufferLinePick<CR>",        desc = "Pick buffer" },
            { "<leader>bP",  "<Cmd>BufferLineTogglePin<CR>",   desc = "Toggle Pin" },
            { "<leader>bco", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close Other Buffers" },
            { "<leader>bcr", "<Cmd>BufferLineCloseRight<CR>",  desc = "Delete Buffers to the Right" },
            { "<leader>bcl", "<Cmd>BufferLineCloseLeft<CR>",   desc = "Delete Buffers to the Left" },
        },
    },

    -- Icons
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },
}
