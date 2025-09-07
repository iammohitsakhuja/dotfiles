return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true, -- Automatically jump forward to textobj
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@parameter.inner"] = "v", -- charwise
            ["@function.outer"] = "V",  -- linewise
            ["@function.inner"] = "V",  -- linewise
            ["@class.outer"] = "V",     -- linewise
            ["@class.inner"] = "V",     -- linewise
          },
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true, -- Whether to set jumps in the jumplist
        },
      })
    end,
    keys = {
      -- Text Object Selection
      { "af", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.outer") end, mode = {"x", "o"}, desc = "Select function outer" },
      { "if", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.inner") end, mode = {"x", "o"}, desc = "Select function inner" },
      { "ac", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.outer") end, mode = {"x", "o"}, desc = "Select class outer" },
      { "ic", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.inner") end, mode = {"x", "o"}, desc = "Select class inner" },
      { "aa", function() require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer") end, mode = {"x", "o"}, desc = "Select parameter outer" },
      { "ia", function() require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner") end, mode = {"x", "o"}, desc = "Select parameter inner" },
      { "ao", function() require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer") end, mode = {"x", "o"}, desc = "Select loop outer" },
      { "io", function() require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner") end, mode = {"x", "o"}, desc = "Select loop inner" },
      { "ai", function() require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer") end, mode = {"x", "o"}, desc = "Select conditional outer" },
      { "ii", function() require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner") end, mode = {"x", "o"}, desc = "Select conditional inner" },
      { "as", function() require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals") end, mode = {"x", "o"}, desc = "Select local scope" },

      -- Movement
      { "]f", function() require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer") end, mode = {"n", "x", "o"}, desc = "Next function start" },
      { "[f", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer") end, mode = {"n", "x", "o"}, desc = "Previous function start" },
      { "]F", function() require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer") end, mode = {"n", "x", "o"}, desc = "Next function end" },
      { "[F", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer") end, mode = {"n", "x", "o"}, desc = "Previous function end" },
      { "]c", function() require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer") end, mode = {"n", "x", "o"}, desc = "Next class start" },
      { "[c", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer") end, mode = {"n", "x", "o"}, desc = "Previous class start" },
      { "]C", function() require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer") end, mode = {"n", "x", "o"}, desc = "Next class end" },
      { "[C", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer") end, mode = {"n", "x", "o"}, desc = "Previous class end" },
      { "]a", function() require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.outer") end, mode = {"n", "x", "o"}, desc = "Next parameter start" },
      { "[a", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.outer") end, mode = {"n", "x", "o"}, desc = "Previous parameter start" },
      { "]o", function() require("nvim-treesitter-textobjects.move").goto_next_start("@loop.outer") end, mode = {"n", "x", "o"}, desc = "Next loop start" },
      { "[o", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@loop.outer") end, mode = {"n", "x", "o"}, desc = "Previous loop start" },
      { "]i", function() require("nvim-treesitter-textobjects.move").goto_next_start("@conditional.outer") end, mode = {"n", "x", "o"}, desc = "Next conditional start" },
      { "[i", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@conditional.outer") end, mode = {"n", "x", "o"}, desc = "Previous conditional start" },

      -- Repeat movement
      { ";", function() require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_next() end, mode = {"n", "x", "o"}, desc = "Repeat last move next" },
      { ",", function() require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_previous() end, mode = {"n", "x", "o"}, desc = "Repeat last move previous" },

      -- Swapping
      { "<leader>sa", function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end, mode = "n", desc = "Swap next parameter" },
      { "<leader>sA", function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner") end, mode = "n", desc = "Swap previous parameter" },
      { "<leader>sf", function() require("nvim-treesitter-textobjects.swap").swap_next("@function.outer") end, mode = "n", desc = "Swap next function" },
      { "<leader>sF", function() require("nvim-treesitter-textobjects.swap").swap_previous("@function.outer") end, mode = "n", desc = "Swap previous function" },
      { "<leader>sc", function() require("nvim-treesitter-textobjects.swap").swap_next("@class.outer") end, mode = "n", desc = "Swap next class" },
      { "<leader>sC", function() require("nvim-treesitter-textobjects.swap").swap_previous("@class.outer") end, mode = "n", desc = "Swap previous class" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects" },
      { "nvim-treesitter/nvim-treesitter-context" },
    }
  },
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
    opts = {
      -- Just install all parsers, they take up ~300MB storage space. Not worth the headache of loading them on-demand.
      ensure_installed = "all",
      auto_install = true,
      fold = { enable = true },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gss",
          node_incremental = "gni",
          scope_incremental = "gsi",
          node_decremental = "gnd",
        },
      },
    },
  },
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
