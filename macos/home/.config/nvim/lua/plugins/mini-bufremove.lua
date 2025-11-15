---@module "lazy"
---@type LazySpec
return {
    "nvim-mini/mini.bufremove",
    name = "mini.bufremove",
    keys = {
        {
            "<leader>bd",
            function()
                require("mini.bufremove").delete(0)
            end,
            mode = "n",
            desc = "Delete buffer",
        },
        {
            "<leader>bD",
            function()
                require("mini.bufremove").delete(0, true)
            end,
            mode = "n",
            desc = "Delete buffer (force)",
        },
    },
    opts = {},
}
