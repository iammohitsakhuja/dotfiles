---@module "lazy"
---@type LazySpec
return {
    "AndreM222/copilot-lualine",
    cond = vim.g.ai_mode == "copilot",
}
