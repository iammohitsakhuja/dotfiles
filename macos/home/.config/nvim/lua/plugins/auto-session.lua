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
            -- Close DAP UI before saving session to avoid restoration issues.
            function()
                local ok, dapui = pcall(require, "dapui")
                if ok then
                    dapui.close()
                end
            end,
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
