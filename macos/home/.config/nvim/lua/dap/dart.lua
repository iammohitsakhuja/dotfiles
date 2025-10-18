-- Dart/Flutter debugging configuration using dart-debug-adapter.

local dap = require("dap")

-- Dart debug configurations.
dap.configurations.dart = {
    {
        type = "dart",
        request = "launch",
        name = "Launch Dart Program",
        dartSdkPath = function()
            local handle = io.popen("which dart")
            if handle then
                local dart_path = handle:read("*a"):gsub("%s+", "")
                handle:close()
                -- Get the SDK path from the dart executable path.
                return dart_path:match("(.*/)")
            end
            return vim.fn.input("Dart SDK path: ", vim.fn.expand("$HOME") .. "/flutter/bin/cache/dart-sdk/", "dir")
        end,
        program = "${file}",
        cwd = "${workspaceFolder}",
        args = {},
    },
    {
        type = "dart",
        request = "launch",
        name = "Launch Flutter App",
        dartSdkPath = function()
            local handle = io.popen("which dart")
            if handle then
                local dart_path = handle:read("*a"):gsub("%s+", "")
                handle:close()
                return dart_path:match("(.*/)")
            end
            return vim.fn.input("Dart SDK path: ", vim.fn.expand("$HOME") .. "/flutter/bin/cache/dart-sdk/", "dir")
        end,
        flutterSdkPath = function()
            local handle = io.popen("which flutter")
            if handle then
                local flutter_path = handle:read("*a"):gsub("%s+", "")
                handle:close()
                return flutter_path:match("(.*/)")
            end
            return vim.fn.input("Flutter SDK path: ", vim.fn.expand("$HOME") .. "/flutter/", "dir")
        end,
        program = "${workspaceFolder}/lib/main.dart",
        cwd = "${workspaceFolder}",
        args = {},
    },
    {
        type = "dart",
        request = "attach",
        name = "Attach to Dart Process",
        dartSdkPath = function()
            local handle = io.popen("which dart")
            if handle then
                local dart_path = handle:read("*a"):gsub("%s+", "")
                handle:close()
                return dart_path:match("(.*/)")
            end
            return vim.fn.input("Dart SDK path: ", vim.fn.expand("$HOME") .. "/flutter/bin/cache/dart-sdk/", "dir")
        end,
        cwd = "${workspaceFolder}",
        vmServiceUri = function()
            return vim.fn.input("VM Service URI: ", "http://127.0.0.1:8181/")
        end,
    },
}
