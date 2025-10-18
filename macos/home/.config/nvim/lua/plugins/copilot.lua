---@module "lazy"
---@type LazySpec
return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = { "BufReadPost", "InsertEnter" },
    cond = vim.g.ai_mode == "copilot",
    dependencies = {
        "copilotlsp-nvim/copilot-lsp",
    },
    ---@module "copilot"
    ---@type CopilotConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
        ---@diagnostic disable-next-line: missing-fields
        panel = {
            enabled = false,
        },

        ---@diagnostic disable-next-line: missing-fields
        suggestion = {
            enabled = true,
            auto_trigger = true,
            hide_during_completion = true,
            debounce = 250, -- Increase debounce to reduce annoyance of suggestions.
            keymap = {
                accept = "<M-;>",
                prev = "<M-[>",
                next = "<M-]>",
                dismiss = "<C-]>",
            },
        },

        nes = {
            enabled = true,
            auto_trigger = true,
            keymap = {
                accept_and_goto = "<leader>p",
                accept = false,
                dismiss = "<Esc>",
            },
        },

        filetypes = {
            markdown = true,
        },
    },
}
