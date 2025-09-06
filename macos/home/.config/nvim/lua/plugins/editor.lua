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
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
          -- `hidden = true` is not supported in text grep commands.
          vimgrep_arguments = vimgrep_arguments,
          preview = {
            -- Ignore preview for files bigger than a threshold.
            filesize_limit = 0.1, -- MB
          }
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
          },
        },
      })

      -- Load extensions after Telescope itself has been setup.
      telescope.load_extension("fzf")
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
}
