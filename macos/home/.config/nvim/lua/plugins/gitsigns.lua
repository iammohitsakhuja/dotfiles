---@module "lazy"
---@type LazySpec
return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    ---@module "gitsigns"
    ---@type Gitsigns.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
            delay = 500,
        },
        max_file_length = 20000,
        on_attach = function(bufnr)
            local gitsigns = require("gitsigns")

            -- Navigation between hunks
            vim.keymap.set("n", "]h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                else
                    gitsigns.nav_hunk("next")
                end
            end, { buffer = bufnr, desc = "Next hunk" })

            vim.keymap.set("n", "[h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                else
                    gitsigns.nav_hunk("prev")
                end
            end, { buffer = bufnr, desc = "Previous hunk" })

            -- Hunk actions
            vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
            vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
            vim.keymap.set("v", "<leader>hs", function()
                gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, { buffer = bufnr, desc = "Stage selected hunk" })
            vim.keymap.set("v", "<leader>hr", function()
                gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, { buffer = bufnr, desc = "Reset selected hunk" })

            -- Buffer actions
            vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { buffer = bufnr, desc = "Stage buffer" })
            vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { buffer = bufnr, desc = "Reset buffer" })

            -- Preview and blame
            vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
            vim.keymap.set(
                "n",
                "<leader>hi",
                gitsigns.preview_hunk_inline,
                { buffer = bufnr, desc = "Preview hunk inline" }
            )
            vim.keymap.set("n", "<leader>hb", function()
                gitsigns.blame()
            end, { buffer = bufnr, desc = "Blame buffer" })
            vim.keymap.set(
                "n",
                "<leader>tb",
                gitsigns.toggle_current_line_blame,
                { buffer = bufnr, desc = "Toggle blame" }
            )

            -- Diff
            vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { buffer = bufnr, desc = "Diff this" })
            vim.keymap.set("n", "<leader>hD", function()
                gitsigns.diffthis("~")
            end, { buffer = bufnr, desc = "Diff this ~" })

            vim.keymap.set("n", "<leader>hQ", function()
                gitsigns.setqflist("all")
            end, { buffer = bufnr, desc = "Add all hunks to quickfix" })
            vim.keymap.set(
                "n",
                "<leader>hq",
                gitsigns.setqflist,
                { buffer = bufnr, desc = "Add buffer hunks to quickfix" }
            )
            vim.keymap.set("n", "<leader>tw", gitsigns.toggle_word_diff, { buffer = bufnr, desc = "Toggle word diff" })

            -- Text object for hunks
            vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk, { buffer = bufnr, desc = "Select hunk" })
        end,
    },
}
