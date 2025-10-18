---@module "lazy"
---@type LazySpec
return {
    "rmagatti/auto-session",
    lazy = false,
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "~/Desktop", "/" },
        pre_save_cmds = {
            "NvimTreeClose",
        },
    },
    keys = {
        { "<leader>ss", "<cmd>AutoSession save<CR>", desc = "Save session" },
        { "<leader>sr", "<cmd>AutoSession restore<CR>", desc = "Restore session" },
        { "<leader>sl", "<cmd>AutoSession search<CR>", desc = "List/search sessions" },
        { "<leader>sd", "<cmd>AutoSession delete<CR>", desc = "Delete session" },
        { "<leader>st", "<cmd>AutoSession toggle<CR>", desc = "Toggle session autosave" },
    },
}
