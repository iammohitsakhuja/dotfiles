---@module "lazy"
---@type LazySpec
return {
    "mfussenegger/nvim-jdtls",
    -- For some reason, `nvim-jdtls` (and even `nvim-java`) plugins need to be loaded eagerly to work properly.
    lazy = false,
    ft = { "java" },
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
        -- This is required for `nvim-jdtls` to automatically setup the `java` debug adapter with `nvim-dap`,
        -- if the latter is available. Hence, we ensure that it's loaded before `nvim-jdtls`.
        "nvim-dap",
    },
}
