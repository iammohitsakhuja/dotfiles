-- Python debugging configuration using debugpy.

local dap = require("dap")

-- Python debug configurations.
dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Launch Current File",
        program = "${file}",
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            -- Check for virtual environment.
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
            else
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end
        end,
    },
    {
        type = "python",
        request = "launch",
        name = "Launch Program with Arguments",
        program = "${file}",
        args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
        end,
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
            else
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end
        end,
    },
    {
        type = "python",
        request = "launch",
        name = "Launch Module",
        module = function()
            return vim.fn.input("Module name: ")
        end,
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
            else
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end
        end,
    },
    {
        type = "python",
        request = "launch",
        name = "Debug Django",
        program = "${workspaceFolder}/manage.py",
        args = { "runserver", "--noreload" },
        django = true,
        console = "integratedTerminal",
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
            else
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end
        end,
    },
    {
        type = "python",
        request = "launch",
        name = "Debug Flask",
        module = "flask",
        env = {
            FLASK_APP = function()
                return vim.fn.input("Flask app module: ", "app.py")
            end,
        },
        args = { "run", "--no-debugger", "--no-reload" },
        console = "integratedTerminal",
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
            else
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end
        end,
    },
    {
        type = "python",
        request = "launch",
        name = "Debug pytest",
        module = "pytest",
        args = { "${file}", "-v" },
        console = "integratedTerminal",
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
            else
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end
        end,
    },
    {
        type = "python",
        request = "attach",
        name = "Attach to Remote",
        connect = {
            host = function()
                return vim.fn.input("Host: ", "localhost")
            end,
            port = function()
                return tonumber(vim.fn.input("Port: ", "5678"))
            end,
        },
    },
}
