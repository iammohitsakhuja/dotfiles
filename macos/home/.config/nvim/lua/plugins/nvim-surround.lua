---@module "lazy"
---@type LazySpec
return {
    "kylechui/nvim-surround",
    version = "*",
    -- Skip lazy loading to avoid missing text object operations that trigger the plugin.
    -- Plugin is lightweight, so we load it without performance concerns but still defer with VeryLazy.
    event = "VeryLazy",
    opts = {},
}
