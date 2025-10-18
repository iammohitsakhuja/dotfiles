-- Java debugging is handled through nvim-jdtls with built-in DAP support.
-- The java-debug-adapter and java-test extensions are installed via mason-nvim-dap.
-- This file provides additional debug configurations if needed.

local dap = require("dap")

-- Java debug configurations.
-- Note: nvim-jdtls will automatically register adapters and configurations.
-- These are supplementary configurations for specific scenarios.
dap.configurations.java = dap.configurations.java or {}

-- Configuration for debugging the current class.
table.insert(dap.configurations.java, {
    type = "java",
    request = "launch",
    name = "Debug (Launch) - Current File",
    mainClass = "${file}",
})

-- Configuration for debugging with custom arguments.
table.insert(dap.configurations.java, {
    type = "java",
    request = "launch",
    name = "Debug (Launch) with Arguments",
    mainClass = function()
        return vim.fn.input("Main class: ")
    end,
    args = function()
        local args_string = vim.fn.input("Arguments: ")
        return vim.split(args_string, " +")
    end,
})

-- Configuration for attaching to a running Java process.
table.insert(dap.configurations.java, {
    type = "java",
    request = "attach",
    name = "Debug (Attach) - Remote",
    hostName = function()
        return vim.fn.input("Host: ", "localhost")
    end,
    port = function()
        return vim.fn.input("Port: ", "5005")
    end,
})
