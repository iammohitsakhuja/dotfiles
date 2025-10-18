---@module "lazy"
---@type LazySpec
return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "theHamsta/nvim-dap-virtual-text",
        "rcarriga/nvim-dap-ui",
    },
    config = function()
        local sign = vim.fn.sign_define

        -- Configure DAP signs for breakpoints and debugging state.
        sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
        sign("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint", linehl = "", numhl = "" })
        sign("DapBreakpointRejected", { text = "○", texthl = "DapBreakpoint", linehl = "", numhl = "" })
        sign("DapLogPoint", { text = "◉", texthl = "DapLogPoint", linehl = "", numhl = "" })
        sign("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })

        -- Set up highlight groups for DAP signs.
        vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" })
        vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
        vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })
        vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#31353f" })

        -- Load language-specific DAP configurations from lua/dap/ directory.
        local dap_config_path = vim.fn.stdpath("config") .. "/lua/dap"
        local config_files = vim.fn.glob(dap_config_path .. "/*.lua", false, true)

        for _, config_file in ipairs(config_files) do
            local ok, err = pcall(dofile, config_file)
            if not ok then
                vim.notify("Error loading DAP config " .. config_file .. ": " .. err, vim.log.levels.ERROR)
            end
        end
    end,
    keys = {
        {
            "<leader>db",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Toggle breakpoint",
        },
        {
            "<leader>dB",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "Set conditional breakpoint",
        },
        {
            "<leader>dc",
            function()
                require("dap").continue()
            end,
            desc = "Continue/Start debugging",
        },
        {
            "<leader>di",
            function()
                require("dap").step_into()
            end,
            desc = "Step into",
        },
        {
            "<leader>do",
            function()
                require("dap").step_over()
            end,
            desc = "Step over",
        },
        {
            "<leader>dO",
            function()
                require("dap").step_out()
            end,
            desc = "Step out",
        },
        {
            "<leader>dr",
            function()
                require("dap").repl.toggle()
            end,
            desc = "Toggle REPL",
        },
        {
            "<leader>dl",
            function()
                require("dap").run_last()
            end,
            desc = "Run last configuration",
        },
        {
            "<leader>dt",
            function()
                require("dap").terminate()
            end,
            desc = "Terminate session",
        },
    },
}
