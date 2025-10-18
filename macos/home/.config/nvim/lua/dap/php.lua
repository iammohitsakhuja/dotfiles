-- PHP debugging configuration using php-debug-adapter (Xdebug).

local dap = require("dap")

-- PHP debug configurations.
dap.configurations.php = {
    {
        type = "php",
        request = "launch",
        name = "Listen for Xdebug",
        port = 9003,
        pathMappings = {
            ["/var/www/html"] = "${workspaceFolder}",
        },
    },
    {
        type = "php",
        request = "launch",
        name = "Launch Current Script",
        program = "${file}",
        cwd = "${workspaceFolder}",
        port = 9003,
        runtimeArgs = { "-dxdebug.start_with_request=yes" },
        env = {
            XDEBUG_CONFIG = "idekey=vscode",
        },
    },
    {
        type = "php",
        request = "launch",
        name = "Launch Built-in Server",
        program = "",
        cwd = "${workspaceFolder}",
        port = 9003,
        serverReadyAction = {
            pattern = "Development Server \\(http://localhost:([0-9]+)\\) started",
            uriFormat = "http://localhost:%s",
            action = "openExternally",
        },
        runtimeArgs = {
            "-dxdebug.start_with_request=yes",
            "-S",
            function()
                return vim.fn.input("Server address: ", "localhost:8000")
            end,
        },
    },
}
