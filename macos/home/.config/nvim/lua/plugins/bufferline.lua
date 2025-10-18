---@module "lazy"
---@type LazySpec
return {
    "akinsho/bufferline.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "catppuccin", "nvim-tree/nvim-web-devicons" },
    ---@module "bufferline"
    ---@type bufferline.UserConfig
    opts = {
        options = {
            diagnostics = "nvim_lsp",
            diagnostics_indicator = function(count, level)
                local icon = level:match("error") and " " or " "
                return " " .. icon .. count
            end,
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    highlight = "Directory",
                    text_align = "center",
                    separator = true,
                },
            },
            get_element_icon = function(element)
                local icon, hl =
                    require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = false })
                return icon, hl
            end,
            sort_by = "insert_after_current",
        },
    },
    config = function(_, opts)
        if (vim.g.colors_name or ""):find("catppuccin") then
            opts.highlights = require("catppuccin.special.bufferline").get_theme()
        end

        require("bufferline").setup(opts)

        -- Fix bufferline when restoring a session
        vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
            callback = function()
                vim.schedule(function()
                    pcall(nvim_bufferline)
                end)
            end,
        })
    end,
    keys = {
        { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
        { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
        { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
        { "<leader>bp", "<Cmd>BufferLinePick<CR>", desc = "Pick buffer" },
        { "<leader>bP", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
        { "<leader>bco", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close Other Buffers" },
        { "<leader>bcr", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
        { "<leader>bcl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    },
}
