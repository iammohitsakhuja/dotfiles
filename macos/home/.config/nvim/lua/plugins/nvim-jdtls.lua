---@module "lazy"
---@type LazySpec
return {
    "mfussenegger/nvim-jdtls",
    -- For some reason, `nvim-jdtls` (and even `nvim-java`) plugins need to be loaded eagerly to work properly.
    lazy = false,
    ft = { "java" },
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
        -- This is required for `nvim-jdtls` to automatically setup the `java` debug adapter with `nvim-dap`,
        -- if the latter is available. Hence, we ensure that it's loaded before `nvim-jdtls`.
        "nvim-dap",
    },
    keys = {
        -- Testing keymaps (<leader>T)
        {
            "<leader>Tc",
            "<cmd>JdtTestClass<CR>",
            ft = "java",
            desc = "Run/debug all tests in current class",
        },
        {
            "<leader>Tn",
            "<cmd>JdtTestNearest<CR>",
            ft = "java",
            desc = "Run/debug test method under cursor",
        },
        {
            "<leader>Tp",
            "<cmd>JdtTestPick<CR>",
            ft = "java",
            desc = "Pick a test to run/debug",
        },
        {
            "<leader>Tg",
            function()
                require("jdtls.tests").generate()
            end,
            ft = "java",
            desc = "Generate tests",
        },
        {
            "<leader>Ts",
            function()
                require("jdtls.tests").goto_subjects()
            end,
            ft = "java",
            desc = "Jump to test/subject",
        },

        -- Java-specific keymaps (<leader>J)
        {
            "<leader>Jo",
            function()
                require("jdtls").organize_imports()
            end,
            ft = "java",
            desc = "Organize imports",
        },
        {
            "<leader>Jv",
            function()
                require("jdtls").extract_variable()
            end,
            ft = "java",
            mode = { "n", "v" },
            desc = "Extract variable",
        },
        {
            "<leader>JV",
            function()
                require("jdtls").extract_variable_all()
            end,
            ft = "java",
            mode = { "n", "v" },
            desc = "Extract variable (replace all)",
        },
        {
            "<leader>Jc",
            function()
                require("jdtls").extract_constant()
            end,
            ft = "java",
            mode = { "n", "v" },
            desc = "Extract constant",
        },
        {
            "<leader>Jm",
            function()
                require("jdtls").extract_method()
            end,
            ft = "java",
            mode = { "n", "v" },
            desc = "Extract method",
        },
        {
            "<leader>Ju",
            "<cmd>JdtUpdateConfig<CR>",
            ft = "java",
            desc = "Update project configuration",
        },
        {
            "<leader>Js",
            function()
                require("jdtls").super_implementation()
            end,
            ft = "java",
            desc = "Go to super implementation",
        },
        {
            "<leader>Jb",
            "<cmd>JdtBytecode<CR>",
            ft = "java",
            desc = "Show bytecode",
        },
        {
            "<leader>Jh",
            "<cmd>JdtJshell<CR>",
            ft = "java",
            desc = "Open jshell with classpath",
        },
        {
            "<leader>JC",
            "<cmd>JdtCompile incremental<CR>",
            ft = "java",
            desc = "Compile project",
        },
    },
}
