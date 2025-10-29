---@module "lazy"
---@type LazySpec
return {
    "JavaHello/spring-boot.nvim",
    -- For some reason, `spring-boot-nvim` plugin also needs to be loaded eagerly to work properly.
    -- Seems to be the case for all Java related plugins.
    lazy = false,
    ft = { "java", "yaml", "jproperties" },
    dependencies = {
        "mfussenegger/nvim-jdtls",
        "nvim-telescope/telescope.nvim",
    },
    ---@module "spring_boot"
    ---@type bootls.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
        -- Use JDK 25 for Spring Boot LS to ensure compatibility with ZGC flags.
        -- This matches the JAVA_HOME set in jdtls.lua and avoids issues with accidentally using older JDKs.
        java_cmd = "/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home/bin/java",
    },
    keys = {
        {
            "<leader>fSa",
            function()
                -- Search for Spring Annotations which are marked with @@ prefix by Spring Boot LS.
                require("telescope.builtin").lsp_workspace_symbols({
                    query = "@@",
                    default_text = "",
                    prompt_title = "Spring Annotations",
                })
            end,
            ft = "java",
            desc = "Find Spring Annotations",
        },
        {
            "<leader>fSb",
            function()
                -- Search for Spring Beans which are marked with @+ prefix by Spring Boot LS.
                require("telescope.builtin").lsp_workspace_symbols({
                    query = "@+",
                    default_text = "",
                    prompt_title = "Spring Beans",
                })
            end,
            ft = "java",
            desc = "Find Spring Beans",
        },
        {
            "<leader>fSe",
            function()
                -- Search for Spring Endpoints which are marked with @/ prefix by Spring Boot LS.
                require("telescope.builtin").lsp_workspace_symbols({
                    query = "@/",
                    default_text = "",
                    prompt_title = "Spring Endpoints",
                })
            end,
            ft = "java",
            desc = "Find Spring Endpoints",
        },
        {
            "<leader>fSf",
            function()
                -- Search for Spring Functions which are marked with @> prefix by Spring Boot LS.
                require("telescope.builtin").lsp_workspace_symbols({
                    query = "@>",
                    default_text = "",
                    prompt_title = "Spring Functions",
                })
            end,
            ft = "java",
            desc = "Find Spring Functions",
        },
    },
}
