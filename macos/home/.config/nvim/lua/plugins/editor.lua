return {
    -- Telescope (fuzzy finder)
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
            "nvim-telescope/telescope-file-browser.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            local config = require("telescope.config")

            -- Clone the default Telescope configuration
            local vimgrep_arguments = { unpack(config.values.vimgrep_arguments) }

            -- Search in hidden/dot files.
            table.insert(vimgrep_arguments, "--hidden")
            -- But not in the `.git` directory.
            table.insert(vimgrep_arguments, "--glob")
            table.insert(vimgrep_arguments, "!**/.git/*")

            telescope.setup({
                defaults = {
                    path_display = { "truncate" },
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                        },
                    },
                    -- `hidden = true` is not supported in text grep commands.
                    vimgrep_arguments = vimgrep_arguments,
                    preview = {
                        -- Ignore preview for files bigger than a threshold.
                        filesize_limit = 0.5, -- MB
                    }
                },
                pickers = {
                    find_files = {
                        find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
                    },
                },
                extensions = {
                    file_browser = {
                        theme = "ivy",
                        hijack_netrw = true,
                        hidden = { file_browser = true, folder_browser = true },
                        grouped = true,
                    },
                },
            })

            -- Load extensions after Telescope itself has been setup.
            telescope.load_extension("fzf")
            telescope.load_extension("file_browser")
        end,
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Telescope help tags" },
            { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Telescope list old files" },
            { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Telescope list available plugin/user commands" },
            { "<leader>fm", "<cmd>Telescope man_pages<cr>", desc = "Telescope list manpages" },
            { "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Telescope list vim registers" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Telescope list keymaps" },
            { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "Telescope file browser" },
            { "<leader>fE", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "Telescope file browser (current dir)" },
            { "<leader>flr", "<cmd>Telescope lsp_references<cr>", desc = "Telescope list LSP references" },
            { "<leader>fli", "<cmd>Telescope lsp_implementations<cr>", desc = "Telescope goto LSP implementation" },
            { "<leader>fld", "<cmd>Telescope lsp_definitions<cr>", desc = "Telescope goto LSP defintion" },
        },
    },

    -- Surround
    {
        "kylechui/nvim-surround",
        version = "^3.1.0",
        -- Skip lazy loading to avoid missing text object operations that trigger the plugin.
        -- Plugin is lightweight, so we load it without performance concerns but still defer with VeryLazy.
        event = "VeryLazy",
        opts = {},
    },

    -- Which Key
    {
        "folke/which-key.nvim",
        -- Lazy loading the plugin does not work: https://github.com/folke/which-key.nvim/issues/981
        -- So we just defer it with VeryLazy.
        event = "VeryLazy",
        opts = {
            preset = "classic",
            plugins = {
                marks = false,
                registers = false,
            },
            win = {
                border = "rounded", -- We need this even if we set `winborder` globally via `vim.opt`
            },
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },

    -- Better Markdown rendering.
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        ft = { "markdown" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            completions = {
                lsp = { enabled = true },
            },
        },
    },

    -- CSS colors
    {
        "catgoose/nvim-colorizer.lua",
        ft = { "css", "scss", "html", "javascript" },
        opts = {
            filetypes = { "css", "scss", "html", "javascript" },
            lazy_load = true,
            user_default_options = {
                RGB = true,
                RRGGBB = true,
                names = true,
                RRGGBBAA = true,
                rgb_fn = true,
                hsl_fn = true,
                css = true,
                css_fn = true,
            },
        },
    },

    -- Highlight special comments such as TODOs.
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = {"BufReadPost", "BufNewFile"},
        cmd = { "TodoFzfLua", "TodoLocList", "TodoQuickFix", "TodoTelescope", "TodoTrouble" },
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, mode = "n", desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, mode = "n", desc = "Previous todo comment" },
        },
        opts = {},
    },
}
