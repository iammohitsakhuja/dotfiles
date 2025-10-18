---@module "lazy"
---@type LazySpec
return {
    "copilotlsp-nvim/copilot-lsp",
    cond = vim.g.ai_mode == "copilot",
    ---@module "copilot-lsp"
    ---@type copilotlsp.config
    opts = {
        ---@diagnostic disable-next-line: missing-fields
        nes = {
            move_count_threshold = 2, -- Reduce threshold to make it less annoying.
        },
    },
    init = function()
        vim.g.copilot_nes_debounce = 500
        -- vim.lsp.enable("copilot_ls")
    end,
}
