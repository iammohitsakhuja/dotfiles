-- Bash debugging configuration using bash-debug-adapter.

local dap = require("dap")

-- Bash debug configurations.
dap.configurations.sh = {
    {
        type = "bashdb",
        request = "launch",
        name = "Launch Current Bash Script",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        pathBash = "bash",
        pathCat = "cat",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        env = {},
        terminalKind = "integrated",
    },
    {
        type = "bashdb",
        request = "launch",
        name = "Launch Bash Script with Arguments",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        pathBash = "bash",
        pathCat = "cat",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
        end,
        env = {},
        terminalKind = "integrated",
    },
}
