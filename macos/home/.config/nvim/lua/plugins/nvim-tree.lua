---@module "lazy"
---@type LazySpec

local function natural_cmp(left, right)
    -- Directories first, then files
    if left.type == "directory" and right.type ~= "directory" then
        return true
    elseif left.type ~= "directory" and right.type == "directory" then
        return false
    end

    -- Both are same type, use natural sorting
    local left_name = left.name:lower()
    local right_name = right.name:lower()

    if left_name == right_name then
        return false
    end

    for i = 1, math.max(string.len(left_name), string.len(right_name)), 1 do
        local l = string.sub(left_name, i, -1)
        local r = string.sub(right_name, i, -1)

        if type(tonumber(string.sub(l, 1, 1))) == "number" and type(tonumber(string.sub(r, 1, 1))) == "number" then
            local l_number = tonumber(string.match(l, "^[0-9]+"))
            local r_number = tonumber(string.match(r, "^[0-9]+"))

            if l_number ~= r_number then
                return l_number < r_number
            end
        elseif string.sub(l, 1, 1) ~= string.sub(r, 1, 1) then
            return l < r
        end
    end
end

return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false, -- Lazy loading is not recommended by plugin authors.
    cmd = {
        "NvimTreeToggle",
        "NvimTreeFocus",
        "NvimTreeFindFileToggle",
        "NvimTreeFindFile",
        "NvimTreeOpen",
        "NvimTreeClose",
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        sort = {
            sorter = function(nodes)
                -- Use custom natural sorting with directories-first.
                table.sort(nodes, natural_cmp)
            end,
        },
        view = {
            width = 50,
            side = "right",
        },
        renderer = {
            group_empty = true,
            highlight_git = "all",
            highlight_modified = "all",
            indent_markers = {
                enable = true,
            },
            icons = {
                show = {
                    git = true,
                },
            },
        },
        filters = {
            dotfiles = false, -- Show dotfiles.
            custom = { ".DS_Store", "^.git$", "node_modules", "vendor" },
        },
        git = {
            enable = true,
            ignore = false,
        },
        actions = {
            open_file = {
                quit_on_open = false,
            },
        },
        -- When opening via system on a Mac, open it using Finder.
        system_open = vim.fn.has("mac") == 1 and {
            cmd = "open",
            args = { "-R" },
        } or nil,
    },
    keys = {
        -- Add keymap for toggling NvimTree
        { "<C-o>", "<cmd>NvimTreeFindFileToggle<CR>", mode = "n", desc = "Toggle Nvim Tree" },
    },
}
