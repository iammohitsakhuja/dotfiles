-- Rust debugging configuration using codelldb.

local dap = require("dap")

-- Rust debug configurations.
dap.configurations.rust = {
    {
        name = "Launch Current File",
        type = "codelldb",
        request = "launch",
        program = function()
            -- Try to find the executable in target/debug.
            local cwd = vim.fn.getcwd()
            local target_dir = cwd .. "/target/debug"

            -- Get the package name from Cargo.toml.
            local cargo_toml = cwd .. "/Cargo.toml"
            if vim.fn.filereadable(cargo_toml) == 1 then
                local lines = vim.fn.readfile(cargo_toml)
                for _, line in ipairs(lines) do
                    local name = line:match('^name%s*=%s*"([^"]+)"')
                    if name then
                        local exe = target_dir .. "/" .. name
                        if vim.fn.filereadable(exe) == 1 then
                            return exe
                        end
                    end
                end
            end

            -- Fallback to user input.
            return vim.fn.input("Path to executable: ", target_dir .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
    },
    {
        name = "Launch with Arguments",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
        end,
    },
    {
        name = "Attach to Process",
        type = "codelldb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        args = {},
    },
}
