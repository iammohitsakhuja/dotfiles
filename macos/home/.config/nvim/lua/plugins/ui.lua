return {
  -- Colorschemes
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "auto", -- latte, frappe, macchiato, mocha
        auto_integrations = true,
      })

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
        lualine_c = {
          { "filename", path = 1 },
          {
            function()
              local msg = "No Active LSP"
              local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
              local clients = vim.lsp.get_clients()
              if next(clients) == nil then
                return msg
              end
              for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                  return client.name
                end
              end
              return msg
            end,
            icon = " LSP:",
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress", "searchcount", "selectioncount" },
        lualine_z = { "location" },
      },
    },
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
      scope = { enabled = false },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "notify" },
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

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
}
