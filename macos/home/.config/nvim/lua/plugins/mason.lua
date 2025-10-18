---@module "lazy"
---@type LazySpec
return {
    "mason-org/mason.nvim",
    dependencies = {
        "j-hui/fidget.nvim",
    },
    ---@module "mason"
    ---@type MasonSettings
    opts = {
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },
        },
    },
}
