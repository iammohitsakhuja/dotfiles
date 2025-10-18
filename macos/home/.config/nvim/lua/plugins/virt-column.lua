---@module "lazy"
---@type LazySpec
return {
    "lukas-reineke/virt-column.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        virtcolumn = "+1", -- Highlight the 1st column after the max line length provided in `.editorconfig`
    },
}
