---@module "lazy"
---@type LazySpec
return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
        "nvim-telescope/telescope-ui-select.nvim",
        "folke/trouble.nvim",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local config = require("telescope.config")
        local open_with_trouble = require("trouble.sources.telescope").open

        -- Clone the default Telescope configuration
        local vimgrep_arguments = { unpack(config.values.vimgrep_arguments) }

        -- Search in hidden/dot files.
        table.insert(vimgrep_arguments, "--hidden")
        -- But not in the `.git` directory.
        table.insert(vimgrep_arguments, "--glob")
        table.insert(vimgrep_arguments, "!**/.git/*")
        -- Follow symlinks.
        table.insert(vimgrep_arguments, "--follow")

        telescope.setup({
            defaults = {
                path_display = { "truncate" },
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-t>"] = open_with_trouble,
                    },
                    n = {
                        ["<C-t>"] = open_with_trouble,
                    },
                },
                -- `hidden = true` is not supported in text grep commands.
                vimgrep_arguments = vimgrep_arguments,
                preview = {
                    -- Ignore preview for files bigger than a threshold.
                    filesize_limit = 0.5, -- MB
                },
            },
            pickers = {
                find_files = {
                    find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
                    follow = true, -- Follow symlinks
                },
            },
            extensions = {
                -- Add any extension specific configuration here.
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown({}),
                },
            },
        })

        -- Load extensions after Telescope itself has been setup.
        telescope.load_extension("fzf")
        telescope.load_extension("ui-select")
        telescope.load_extension("fidget")
    end,
    keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
        { "<leader>fs", "<cmd>Telescope grep_string<cr>", desc = "Telescope grep string under cursor" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Telescope help tags" },
        { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Telescope list old files" },
        { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Telescope list available plugin/user commands" },
        { "<leader>fm", "<cmd>Telescope man_pages<cr>", desc = "Telescope list manpages" },
        { "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Telescope list vim registers" },
        { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Telescope list keymaps" },
        { "<leader>flr", "<cmd>Telescope lsp_references<cr>", desc = "Telescope list LSP references" },
        { "<leader>fli", "<cmd>Telescope lsp_implementations<cr>", desc = "Telescope goto LSP implementation" },
        { "<leader>fld", "<cmd>Telescope lsp_definitions<cr>", desc = "Telescope goto LSP defintion" },
    },
}
