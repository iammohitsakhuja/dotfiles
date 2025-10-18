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

        -- Automatically open and close dap-ui when debugging sessions start and end.
        dap.listeners.before.attach["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.launch["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end
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
