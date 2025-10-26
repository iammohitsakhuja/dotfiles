---@module "lazy"
---@type LazySpec
return {
    "nvim-mini/mini.bufremove",
    name = "mini.bufremove",
    version = false,
    lazy = false,
    opts = {},
    config = function(_, opts)
        require("mini.bufremove").setup()
    end,
}
