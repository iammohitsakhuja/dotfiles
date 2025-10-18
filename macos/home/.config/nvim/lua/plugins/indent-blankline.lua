---@module "lazy"
---@type LazySpec
return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    ---@module "ibl"
    ---@type ibl.config
    opts = {
        indent = {
            char = "│",
            tab_char = "│",
        },
        scope = {
            enabled = true,
        },
        exclude = {
            filetypes = { "help", "alpha", "dashboard", "NvimTree", "Trouble", "lazy", "notify" },
        },
    },
}
