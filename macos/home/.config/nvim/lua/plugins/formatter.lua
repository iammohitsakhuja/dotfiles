---@module "lazy"
---@type LazySpec
return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = {
            "ConformInfo",
        },
        ---@module "conform"
        ---@type conform.setupOpts
        opts = {
            formatters = {
                jq = {
                    args = { "--indent", "4", "." },
                },
            },
            formatters_by_ft = {
                bash = { "shellcheck", "shfmt" },
                css = { "biome-check", "prettier", stop_after_first = true },
                dart = { "dart_format" },
                go = { "goimports", "gofmt", stop_after_first = true },
                html = { "biome-check", "prettier", stop_after_first = true },
                java = { "google-java-format" },
                javascript = { "biome-check", "prettier", stop_after_first = true },
                javascriptreact = { "biome-check", "prettier", stop_after_first = true },
                json = { "biome-check", "prettier", "jq", stop_after_first = true },
                jsonc = { "biome-check", "prettier", "jq", stop_after_first = true },
                less = { "prettier" },
                lua = { "stylua" },
                python = function(bufnr)
                    -- Check if ruff is available
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_organize_imports", "ruff_fix", "ruff_format" }
                    else
                        return { "isort", "black" }
                    end
                end,
                rust = { "rustfmt" },
                scss = { "prettier" },
                sh = { "shellcheck", "shfmt" },
                typescript = { "biome-check", "prettier", stop_after_first = true },
                typescriptreact = { "biome-check", "prettier", stop_after_first = true },
                yaml = { "prettier", "yamlfmt", "yq", stop_after_first = true },
                -- Fallback formatters for file types without explicit configuration
                ["_"] = { "trim_whitespace", "trim_newlines" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            format_on_save = function(bufnr)
                -- Disable with a global or buffer-local variable.
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end

                -- Disable autoformat for files in a certain path.
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                if bufname:match("/node_modules/") then
                    return
                end

                return { timeout_ms = 2000, async = false }
            end,
        },
        keys = {
            {
                "<leader>cf",
                "<cmd>ConformFormat<cr>",
                mode = "n",
                desc = "Format buffer",
            },
            {
                "<leader>cf",
                ":'<,'>ConformFormat<cr>",
                mode = "v",
                desc = "Format selection",
            },
            {
                "<leader>cF",
                "<cmd>ConformFormat injected<cr>",
                mode = "n",
                desc = "Format Injected Languages",
            },
            {
                "<leader>cF",
                ":'<,'>ConformFormat injected<cr>",
                mode = "v",
                desc = "Format Injected Languages in selection",
            },
            {
                "<leader>ct",
                "<cmd>ConformFormatToggle<cr>",
                mode = "n",
                desc = "Toggle auto-formatting for this buffer",
            },
            {
                "<leader>cT",
                "<cmd>ConformFormatToggle!<cr>",
                mode = "n",
                desc = "Toggle auto-formatting for the session",
            },
            {
                "<leader>ci",
                "<cmd>ConformInfo<cr>",
                mode = "n",
                desc = "Show conform info",
            },
        },
        init = function()
            -- Initialize autoformat state (default: enabled)
            if vim.g.disable_autoformat == nil then
                vim.g.disable_autoformat = false
            end

            -- Set conform as the formatter when using built-in formatting via `gq`.
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
}
