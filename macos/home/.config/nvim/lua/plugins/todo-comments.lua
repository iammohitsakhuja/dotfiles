---@module "lazy"
---@type LazySpec
return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TodoFzfLua", "TodoLocList", "TodoQuickFix", "TodoTelescope", "TodoTrouble" },
    keys = {
        {
            "]t",
            function()
                require("todo-comments").jump_next()
            end,
            mode = "n",
            desc = "Next todo comment",
        },
        {
            "[t",
            function()
                require("todo-comments").jump_prev()
            end,
            mode = "n",
            desc = "Previous todo comment",
        },
    },
    opts = {},
}
