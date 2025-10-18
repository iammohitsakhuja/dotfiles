-- Lua debugging configuration using local-lua-debugger-vscode.

local dap = require("dap")

-- Lua debug configurations.
dap.configurations.lua = {
    {
        type = "local-lua",
        request = "launch",
        name = "Launch Current Lua File",
        cwd = "${workspaceFolder}",
        program = {
            lua = "lua",
            file = "${file}",
        },
    },
    {
        type = "local-lua",
        request = "launch",
        name = "Launch Lua File with Arguments",
        cwd = "${workspaceFolder}",
        program = {
            lua = "lua",
            file = "${file}",
            args = function()
                local args_string = vim.fn.input("Arguments: ")
                return vim.split(args_string, " +")
            end,
        },
    },
    {
        type = "local-lua",
        request = "launch",
        name = "Debug Neovim Plugin",
        cwd = "${workspaceFolder}",
        program = {
            command = vim.fn.exepath("nvim"),
            args = { "--headless", "-u", "NONE", "-c", "lua require('${file}')" },
        },
    },
}
