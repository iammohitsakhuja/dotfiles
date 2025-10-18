---@module "lazy"
---@type LazySpec
return {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
        ---@module "fidget.notification"
        ---@type Config
        notification = {
            override_vim_notify = true,
            window = {
                winblend = 0,
                avoid = {
                    "NvimTree",
                },
            },
        },
    },
}
