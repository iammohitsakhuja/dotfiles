---@module "lazy"
---@type LazySpec
return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    dependencies = {
        { "nvim-treesitter/nvim-treesitter-textobjects" },
        { "nvim-treesitter/nvim-treesitter-context" },
    },
}
