return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    dependencies = {
    },
    init = function()
      -- Enable treesitter for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash", "sh",
          "c", "cpp",
          "css",
          "dart",
          "dockerfile",
          "editorconfig",
          "gitconfig",
          "gitcommit",
          "gitignore",
          "go",
          "gomod",
          "gosum",
          "helm",
          "html",
          "java",
          "javascript", "javascriptreact",
          "json", "jsonc",
          "jsx",
          "lua",
          "make",
          "markdown",
          "nginx",
          "properties",
          "proto",
          "python",
          "rust",
          "scss",
          "sql",
          "sshconfig",
          "toml",
          "typescript", "typescriptreact",
          "vim",
          "yaml", "yml",
        },
        callback = function()
          -- Provides highlighting.
          vim.treesitter.start()

          -- Provides folding.
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldlevel = 99  -- Start with all folds open

          -- Provides indentation.
          -- Note: Might want to replace this API once Neovim provides a built-in indentation API
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
    config = function()
      -- parser installation
      local parsers = {
          "bash",
          "c",
          "cpp",
          "css",
          "dart",
          "dockerfile",
          "editorconfig",
          "git_config",
          "gitcommit",
          "gitignore",
          "go",
          "gomod",
          "gosum",
          "helm",
          "html",
          "java",
          "javascript",
          "json",
          "jsx",
          "lua",
          "make",
          "markdown",
          "markdown_inline",
          "nginx",
          "properties",
          "proto",
          "python",
          "rust",
          "scss",
          "sql",
          "ssh_config",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
      }

      -- Install parsers synchronously (useful for initial setup)
      -- This will wait up to 5 minutes for all parsers to install
      require("nvim-treesitter").install(parsers):wait(300000)
    end,
  },
}
