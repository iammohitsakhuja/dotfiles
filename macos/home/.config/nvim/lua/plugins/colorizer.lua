---@module "lazy"
---@type LazySpec
return {
    "catgoose/nvim-colorizer.lua",
    ft = { "css", "scss", "dart", "html", "javascript", "lua", "php", "toml", "xml", "yaml" },
    opts = {
        filetypes = { "css", "scss", "dart", "html", "javascript", "lua", "php", "toml", "xml", "yaml" },
        lazy_load = true,
        user_default_options = {
            RGB = true,
            RRGGBB = true,
            names = true,
            RRGGBBAA = true,
            rgb_fn = true,
            hsl_fn = true,
            css = true,
            css_fn = true,
        },
    },
}
