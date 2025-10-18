-- Go debugging configuration using delve.

local dap = require("dap")

-- Go debug configurations.
dap.configurations.go = {
    {
        type = "delve",
        name = "Debug Current File",
        request = "launch",
        program = "${file}",
    },
    {
        type = "delve",
        name = "Debug Package",
        request = "launch",
        program = "${fileDirname}",
    },
    {
        type = "delve",
        name = "Debug with Arguments",
        request = "launch",
        program = "${file}",
        args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
        end,
    },
    {
        type = "delve",
        name = "Debug Test (Current Function)",
        request = "launch",
        mode = "test",
        program = "${file}",
    },
    {
        type = "delve",
        name = "Debug Test (All in Package)",
        request = "launch",
        mode = "test",
        program = "${fileDirname}",
    },
    {
        type = "delve",
        name = "Attach to Process",
        mode = "local",
        request = "attach",
        processId = require("dap.utils").pick_process,
    },
    {
        type = "delve",
        name = "Attach to Remote",
        mode = "remote",
        request = "attach",
        connect = {
            host = function()
                return vim.fn.input("Host: ", "127.0.0.1")
            end,
            port = function()
                return vim.fn.input("Port: ", "38697")
            end,
        },
        substitutePath = {
            {
                from = "${workspaceFolder}",
                to = function()
                    return vim.fn.input("Remote path: ", "/app")
                end,
            },
        },
    },
}
