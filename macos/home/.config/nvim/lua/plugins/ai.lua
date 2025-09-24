return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        dependencies = {
            {
                "copilotlsp-nvim/copilot-lsp",
                init = function()
                    vim.g.copilot_nes_debounce = 500
                end,
            },
        },
        opts = {
            nes = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept_and_goto = "<leader>p",
                    accept = false,
                    dismiss = "<Esc>",
                },
            },
        },
        init = function()
            -- Hide Copilot suggestions when completion menu is open.
            vim.api.nvim_create_autocmd("User", {
                pattern = "BlinkCmpMenuOpen",
                callback = function()
                    vim.b.copilot_suggestion_hidden = true
                end,
            })

            -- Show Copilot suggestions again when completion menu is closed.
            vim.api.nvim_create_autocmd("User", {
                pattern = "BlinkCmpMenuClose",
                callback = function()
                    vim.b.copilot_suggestion_hidden = false
                end,
            })
        end,
    },
}
