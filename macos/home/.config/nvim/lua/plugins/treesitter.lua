return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
      { "nvim-treesitter/nvim-treesitter-context" },
      -- "JoosepAlviste/nvim-ts-context-commentstring",
    },
    init = function()
      -- Custom syntax mappings for special filetypes
      -- Inspired by: https://github.com/luisdavim/dotfiles/blob/5809879e95a0c01275d7687078cf4d166077a04e/files/config/nvim/init.lua
      -- Add mappings here if needed, e.g.: ['tiltfile'] = 'starlark'
      local syntax_map = {
        -- Example: ['tiltfile'] = 'starlark',
      }

      -- Cache modules and parser data for performance
      local treesitter, ts_config
      local installed_parsers_set = {}
      local available_parsers_set = {}
      local cache_initialized = false

      local function init_cache()
        if cache_initialized then return end

        treesitter = require('nvim-treesitter')
        ts_config = require('nvim-treesitter.config')

        -- Cache installed parsers as a set for O(1) lookup
        local installed = ts_config.get_installed('parsers')
        for _, parser in ipairs(installed) do
          print("_: " .. _ .. ", parser: " .. parser)
          installed_parsers_set[parser] = true
        end

        -- Cache available parsers as a set for O(1) lookup
        local available = ts_config.get_available()
        for _, parser in ipairs(available) do
          available_parsers_set[parser] = true
        end

        cache_initialized = true
      end

      local function update_parser_cache(parser_name)
        installed_parsers_set[parser_name] = true
      end

      local function ts_start(bufnr, parser_name)
        -- Start treesitter to enable highlighting
        vim.treesitter.start(bufnr, parser_name)

        -- Use regex based syntax-highlighting as fallback as some plugins might need it
        vim.bo[bufnr].syntax = "ON"

        -- Use treesitter for folds
        vim.wo.foldlevel = 99
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

        -- Note: The following commented line does NOT work as this API was reverted from Neovim sometime after its
        -- introduction. It is now `vim.lsp.foldtext()`.
        -- TODO: Move this when we introduce LSP.
        -- vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"

        -- Use treesitter for indentation
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      -- Auto-install and start parsers for any buffer
      vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Enable Treesitter",
        callback = function(event)
          local bufnr = event.buf
          local filetype = event.match

          -- Skip if no filetype
          if filetype == "" then
            return
          end

          -- Get parser name based on filetype
          local lang = vim.tbl_get(syntax_map, filetype)
          if lang == nil then
            lang = filetype
          else
            vim.notify("Using language override " .. lang)
          end
          local parser_name = vim.treesitter.language.get_lang(lang)
          if not parser_name then
            -- Silently skip if no parser is available for this filetype
            return
          end

          -- Initialize cache on first use
          init_cache()

          -- Check if parser is available using cached data
          if not available_parsers_set[parser_name] then
            return
          end

          -- Check if parser is already installed using cached data
          if not installed_parsers_set[parser_name] then
            -- If not installed, install parser asynchronously and start treesitter
            vim.notify("Installing parser for " .. parser_name, vim.log.levels.INFO)
            treesitter.install({ parser_name }):await(
              function()
                -- Update cache after successful installation
                update_parser_cache(parser_name)
                ts_start(bufnr, parser_name)
              end
            )
            return
          end

          -- Start treesitter for this buffer
          ts_start(bufnr, parser_name)
        end,
      })
    end,
    config = function()
      local treesitter = require('nvim-treesitter')
      local ts_config = require('nvim-treesitter.config')

      -- Configure treesitter
      treesitter.setup({
        -- Directory to install parsers and queries to
        install_dir = vim.fn.stdpath('data') .. '/site'
      })

      -- Configure treesitter-textobjects
      require('nvim-treesitter-textobjects').setup()

      -- Configure treesitter-context
      require('treesitter-context').setup()

      -- List of parsers to ensure are installed
      local ensure_installed = {
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

      -- Install only missing parsers asynchronously
      local already_installed = ts_config.get_installed('parsers')
      local parsers_to_install = vim.iter(ensure_installed)
        :filter(function(parser) return not vim.tbl_contains(already_installed, parser) end)
        :totable()

      if #parsers_to_install > 0 then
        vim.notify("Installing " .. #parsers_to_install .. " treesitter parsers: " .. table.concat(parsers_to_install, ", "), vim.log.levels.INFO)
        treesitter.install(parsers_to_install)
      end
    end,
  },
}
