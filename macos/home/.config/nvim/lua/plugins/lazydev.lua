---@module "lazy"
---@type LazySpec
return {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    cmd = "LazyDev",
    opts = {
        library = {
            { "nvim-dap-ui" }, -- Recommended by `nvim-dap-ui` plugin authors to get its completions.
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    },
}
