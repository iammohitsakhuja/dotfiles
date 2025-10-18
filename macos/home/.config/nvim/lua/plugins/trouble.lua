---@module "lazy"
---@type LazySpec
return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble" },
    ---@module "trouble"
    ---@type trouble.Config
    opts = {
        ---@type trouble.Window.opts
        win = {
            size = {
                height = 18,
                width = 50,
            },
        },
        ---@type trouble.Window.opts
        preview = {
            border = "none",
        },
        open_no_results = true,
        focus = true,
        modes = {
            diagnostics = {
                auto_refresh = true,
            },
            -- Provide titles to modes for which Trouble does not provide any.
            lsp = {
                title = "LSP",
                win = {
                    position = "right",
                },
            },
            loclist = {
                title = "Location List",
            },
            qflist = {
                title = "Quickfix List",
            },
        },
    },
    keys = {
        {
            "]d",
            function()
                if require("trouble").is_open() then
                    require("trouble").next({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.diagnostic.goto_next)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Next diagnostic",
        },
        {
            "[d",
            function()
                if require("trouble").is_open() then
                    require("trouble").prev({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.diagnostic.goto_prev)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Previous diagnostic",
        },
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle filter.buf=0 title='Buffer Diagnostics'<cr>",
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<leader>xX",
            "<cmd>Trouble diagnostics toggle title='Diagnostics'<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>cs",
            "<cmd>Trouble symbols toggle focus=false<cr>",
            desc = "Symbols (Trouble)",
        },
        {
            "<leader>cl",
            "<cmd>Trouble lsp toggle focus=false<cr>",
            desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
            "<leader>xL",
            "<cmd>Trouble loclist toggle<cr>",
            desc = "Location List (Trouble)",
        },
        {
            "<leader>xQ",
            "<cmd>Trouble qflist toggle<cr>",
            desc = "Quickfix List (Trouble)",
        },
    },
}
