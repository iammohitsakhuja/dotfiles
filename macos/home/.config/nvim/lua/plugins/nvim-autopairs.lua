---@module "lazy"
---@type LazySpec
return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
        check_ts = true, -- Enable treesitter integration
        ts_config = {
            -- Don't add pairs for <language> in <nodes>
            lua = { "string" },
            javascript = { "template_string" },
            typescript = { "template_string" },
        },
        fast_wrap = {
            map = "<M-e>", -- Alt+e to wrap selections
            chars = { "{", "[", "(", '"', "'" },
            pattern = [=[[%'%"%)%>%]%)%}%,]]=],
            end_key = "$",
            keys = "qwertyuiopzxcvbnmasdfghjkl",
            check_comma = true,
            highlight = "Search",
            highlight_grey = "Comment",
        },
    },
}
