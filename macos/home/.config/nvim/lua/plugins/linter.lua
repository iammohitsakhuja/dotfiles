return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
        {
            "<leader>l",
            function()
                require("lint").try_lint()
            end,
            desc = "Trigger linting for current file",
        },
    },
    init = function()
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                require("lint").try_lint()
            end,
        })
    end,
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            -- JavaScript/TypeScript
            javascript = { "biomejs", "eslint" },
            typescript = { "biomejs", "eslint" },
            javascriptreact = { "biomejs", "eslint" },
            typescriptreact = { "biomejs", "eslint" },

            -- Python
            python = { "ruff" },

            -- Shell/Bash
            sh = { "shellcheck" },
            bash = { "shellcheck" },

            -- Docker
            dockerfile = { "hadolint" },

            -- YAML (includes Helm charts)
            yaml = { "yamllint" },
            yml = { "yamllint" },

            -- Go
            go = { "golangcilint" },

            -- Rust
            rust = { "clippy" },

            -- PHP
            php = { "phpcs" },

            -- Web Technologies
            css = { "stylelint" },
            scss = { "stylelint" },
            html = { "htmlhint" },

            -- Data Formats
            json = { "biomejs", "jsonlint" },

            -- Documentation
            markdown = { "markdownlint" },

            -- Protocol Buffers
            proto = { "protolint" },
        }
    end,
}
