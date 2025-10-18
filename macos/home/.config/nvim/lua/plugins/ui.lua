--- @param trunc_width number trunctates component when screen width is less then trunc_width
--- @param trunc_len number truncates component to trunc_len number of chars
--- @param hide_width number? hides component when window width is smaller then hide_width
--- @param no_ellipsis boolean? whether to disable adding '...' at end after truncation
--- return function that can format the component accordingly
local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
    return function(str)
        local win_width = vim.fn.winwidth(0)
        if hide_width and win_width < hide_width then
            return ""
        elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
            return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
        end
        return str
    end
end

local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
        }
    end
end

local function natural_cmp(left, right)
    -- Directories first, then files
    if left.type == "directory" and right.type ~= "directory" then
        return true
    elseif left.type ~= "directory" and right.type == "directory" then
        return false
    end

    -- Both are same type, use natural sorting
    local left_name = left.name:lower()
    local right_name = right.name:lower()

    if left_name == right_name then
        return false
    end

    for i = 1, math.max(string.len(left_name), string.len(right_name)), 1 do
        local l = string.sub(left_name, i, -1)
        local r = string.sub(right_name, i, -1)

        if type(tonumber(string.sub(l, 1, 1))) == "number" and type(tonumber(string.sub(r, 1, 1))) == "number" then
            local l_number = tonumber(string.match(l, "^[0-9]+"))
            local r_number = tonumber(string.match(r, "^[0-9]+"))

            if l_number ~= r_number then
                return l_number < r_number
            end
        elseif string.sub(l, 1, 1) ~= string.sub(r, 1, 1) then
            return l < r
        end
    end
end

---@module "lazy"
---@type LazySpec
return {
    -- Colorschemes
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        ---@module "catppuccin"
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
                dark = "mocha",
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

    {
        "AndreM222/copilot-lualine",
        cond = vim.g.ai_mode == "copilot",
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "lewis6991/gitsigns.nvim",
            vim.g.ai_mode == "copilot" and "AndreM222/copilot-lualine" or "milanglacier/minuet-ai.nvim",
        },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true, -- Have a single statusline instead of one per each split
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = {
                        { "mode", fmt = trunc(80, 4, nil, true) },
                    },
                    lualine_b = {
                        { "b:gitsigns_head", icon = "" },
                        {
                            "diff",
                            source = diff_source,
                            symbols = {
                                added = " ",
                                modified = " ",
                                removed = " ",
                            },
                        },
                        {
                            "diagnostics",
                            symbols = {
                                error = "󰅚 ",
                                warn = "󰀪 ",
                                info = "󰋽 ",
                                hint = "󰌶 ",
                            },
                        },
                    },
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,
                            path = 1,
                            fmt = trunc(90, 30, 50),
                            symbols = {
                                modified = "● ",
                                readonly = "󰌾 ",
                                unnamed = "[]",
                                newfile = "󰎔 ",
                            },
                        },
                    },
                    lualine_x = {
                        {
                            function()
                                return require("auto-session.lib").current_session_name(true)
                            end,
                            icon = "",
                            fmt = trunc(100, 20),
                        },
                        "lsp_status",
                        vim.g.ai_mode == "copilot" and "copilot" or vim.g.ai_mode == "minimal" and {
                            require("minuet.lualine"),
                            display_on_idle = true,
                        } or "",
                        "encoding",
                        "fileformat",
                        "filetype",
                    },
                    lualine_y = { "progress", "searchcount", "selectioncount" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false, -- Lazy loading is not recommended by plugin authors.
        cmd = {
            "NvimTreeToggle",
            "NvimTreeFocus",
            "NvimTreeFindFileToggle",
            "NvimTreeFindFile",
            "NvimTreeOpen",
            "NvimTreeClose",
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            sort = {
                sorter = function(nodes)
                    -- Use custom natural sorting with directories-first.
                    table.sort(nodes, natural_cmp)
                end,
            },
            view = {
                width = 50,
                side = "right",
            },
            renderer = {
                group_empty = true,
                highlight_git = "all",
                highlight_modified = "all",
                indent_markers = {
                    enable = true,
                },
                icons = {
                    show = {
                        git = true,
                    },
                },
            },
            filters = {
                dotfiles = false, -- Show dotfiles.
                custom = { ".DS_Store", "^.git$", "node_modules", "vendor" },
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
            -- When opening via system on a Mac, open it using Finder.
            system_open = vim.fn.has("mac") == 1 and {
                cmd = "open",
                args = { "-R" },
            } or nil,
        },
        keys = {
            -- Add keymap for toggling NvimTree
            { "<C-o>", "<cmd>NvimTreeFindFileToggle<CR>", mode = "n", desc = "Toggle Nvim Tree" },
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
                filetypes = { "help", "alpha", "dashboard", "NvimTree", "Trouble", "lazy", "notify" },
            },
        },
    },

    -- Virtual Column
    {
        "lukas-reineke/virt-column.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            virtcolumn = "+1", -- Highlight the 1st column after the max line length provided in `.editorconfig`
        },
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
        },
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
                    local icon, hl =
                        require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = false })
                    return icon, hl
                end,
                sort_by = "insert_after_current",
            },
        },
        config = function(_, opts)
            if (vim.g.colors_name or ""):find("catppuccin") then
                opts.highlights = require("catppuccin.special.bufferline").get_theme()
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
            { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
            { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
            { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
            { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
            { "<leader>bp", "<Cmd>BufferLinePick<CR>", desc = "Pick buffer" },
            { "<leader>bP", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
            { "<leader>bco", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close Other Buffers" },
            { "<leader>bcr", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
            { "<leader>bcl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
        },
    },

    -- Icons
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },
}
