---@module "lazy"
---@type LazySpec
return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
    },
    config = function()
        local dap, dapui = require("dap"), require("dapui")

        -- Setup dap-ui with default configuration.
        ---@diagnostic disable-next-line: missing-fields
        dapui.setup({
            floating = {
                border = "rounded",
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
            render = {
                indent = 1,
                max_value_lines = 100,
            },
        })

        -- Automatically open dap-ui when debugging sessions start.
        dap.listeners.before.attach["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.launch["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        -- Note: We don't auto-close on event_terminated or event_exited to allow reviewing
        -- test results, output, and final variable states after successful execution.
        -- Users can manually close with <leader>dut or q in the DAP UI windows.
    end,
    keys = {
        {
            "<leader>dut",
            function()
                require("dapui").toggle()
            end,
            desc = "Toggle DAP UI",
        },
        {
            "<leader>due",
            function()
                require("dapui").eval()
            end,
            mode = { "n", "v" },
            desc = "Evaluate expression",
        },
        {
            "<leader>duf",
            function()
                ---@diagnostic disable-next-line: missing-fields
                require("dapui").float_element("scopes", { enter = true })
            end,
            desc = "Float scopes",
        },
    },
}
