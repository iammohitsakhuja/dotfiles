---@module "lazy"
---@type LazySpec
return {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
        "mason-org/mason.nvim",
        "mfussenegger/nvim-dap",
    },
    opts = {
        automatic_installation = true,

        -- NOTE: Use DAP adapter names, not Mason package names.
        ensure_installed = {
            "javadbg", -- Maps to java-debug-adapter
            "javatest", -- Maps to java-test
            "js", -- Maps to js-debug-adapter
            "python", -- Maps to debugpy
            "delve", -- Go
            "codelldb", -- Rust, C, C++
            "bash", -- Maps to bash-debug-adapter
            "dart", -- Maps to dart-debug-adapter
            "php", -- Maps to php-debug-adapter
        },

        -- Automatically setup debug adapters using default configurations.
        handlers = {
            function(config)
                -- Default handler applies to all adapters.
                -- mason-nvim-dap knows how to properly configure each adapter.
                require("mason-nvim-dap").default_setup(config)
            end,
        },
    },
}
