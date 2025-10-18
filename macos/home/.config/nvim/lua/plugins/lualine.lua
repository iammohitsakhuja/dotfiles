---@module "lazy"
---@type LazySpec

--- @param trunc_width number trunctates component when screen width is less then trunc_width
--- @param trunc_len number truncates component to trunc_len number of chars
--- @param hide_width number? hides component when window width is smaller then hide_width
--- @param no_ellipsis boolean? whether to disable adding '...' at end after truncation
--- return function that can format the component accordingly
local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
    return function(str)
        local win_width = vim.fn.winwidth(0)
        if hide_width and win_width < hide_width then
            return ""
        elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
            return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
        end
        return str
    end
end

local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
        }
    end
end

return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "lewis6991/gitsigns.nvim",
        vim.g.ai_mode == "copilot" and "AndreM222/copilot-lualine" or "milanglacier/minuet-ai.nvim",
    },
    config = function()
        require("lualine").setup({
            options = {
                theme = "auto",
                globalstatus = true, -- Have a single statusline instead of one per each split
                component_separators = { left = "│", right = "│" },
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = {
                    { "mode", fmt = trunc(80, 4, nil, true) },
                },
                lualine_b = {
                    { "b:gitsigns_head", icon = "" },
                    {
                        "diff",
                        source = diff_source,
                        symbols = {
                            added = " ",
                            modified = " ",
                            removed = " ",
                        },
                    },
                    {
                        "diagnostics",
                        symbols = {
                            error = "󰅚 ",
                            warn = "󰀪 ",
                            info = "󰋽 ",
                            hint = "󰌶 ",
                        },
                    },
                },
                lualine_c = {
                    {
                        "filename",
                        file_status = true,
                        path = 1,
                        fmt = trunc(90, 30, 50),
                        symbols = {
                            modified = "● ",
                            readonly = "󰌾 ",
                            unnamed = "[]",
                            newfile = "󰎔 ",
                        },
                    },
                },
                lualine_x = {
                    {
                        function()
                            return require("auto-session.lib").current_session_name(true)
                        end,
                        icon = "",
                        fmt = trunc(100, 20),
                    },
                    "lsp_status",
                    vim.g.ai_mode == "copilot" and "copilot" or vim.g.ai_mode == "minimal" and {
                        require("minuet.lualine"),
                        display_on_idle = true,
                    } or "",
                    "encoding",
                    "fileformat",
                    "filetype",
                },
                lualine_y = { "progress", "searchcount", "selectioncount" },
                lualine_z = { "location" },
            },
        })
    end,
}
