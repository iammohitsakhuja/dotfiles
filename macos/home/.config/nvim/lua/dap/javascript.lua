-- JavaScript debugging configuration using js-debug-adapter.

local dap = require("dap")

-- Configure the js-debug-adapter.
-- This is required because the previous `node-debug2-adapter` and `chrome-debug-adapter` have been discontinued,
-- however, `mason-nvim-dap` still only contains those adapters' configuration.
-- Hence, for now, we register `pwa-node` and `pwa-chrome` adapters ourselves.
-- Use conditional assignment to avoid overwriting if already defined (order-independent).
dap.adapters["pwa-node"] = dap.adapters["pwa-node"]
    or {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "js-debug-adapter",
            args = { "${port}" },
        },
    }

dap.adapters["pwa-chrome"] = dap.adapters["pwa-chrome"]
    or {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "js-debug-adapter",
            args = { "${port}" },
        },
    }

-- JavaScript debug configurations.
dap.configurations.javascript = {
    {
        type = "pwa-node",
        request = "launch",
        name = "Launch Current File (Node.js)",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
        console = "integratedTerminal",
        resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
        },
    },
    {
        type = "pwa-node",
        request = "launch",
        name = "Launch Program (Node.js)",
        program = function()
            return vim.fn.input("Path to JavaScript file: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
        console = "integratedTerminal",
        resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
        },
    },
    {
        type = "pwa-node",
        request = "attach",
        name = "Attach to Process",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
        resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
        },
    },
    {
        type = "pwa-chrome",
        request = "launch",
        name = "Launch Chrome for Debugging",
        url = function()
            return vim.fn.input("Enter URL: ", "http://localhost:3000")
        end,
        webRoot = "${workspaceFolder}",
        userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
        sourceMaps = true,
        resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
        },
    },
    {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jest Tests",
        runtimeExecutable = "node",
        runtimeArgs = {
            "./node_modules/jest/bin/jest.js",
            "--runInBand",
        },
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        skipFiles = { "<node_internals>/**" },
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
    },
}
