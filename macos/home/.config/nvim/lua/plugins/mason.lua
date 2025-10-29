---@module "lazy"
---@type LazySpec
return {
    "mason-org/mason.nvim",
    dependencies = {
        "j-hui/fidget.nvim",
    },
    ---@module "mason"
    ---@type MasonSettings
    opts = {
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },
        },
    },
    config = function(_, opts)
        require("mason").setup(opts)

        -- Ensure additional tools are installed.
        local mason_registry = require("mason-registry")
        local ensure_installed = {
            -- Spring Boot Tools provides jdtls extensions (loaded via jdtls bundles).
            -- For full Spring Boot support (application.properties autocomplete, request mapping
            -- code lenses, etc.), additional setup is required:
            --   1. Configure the Spring Boot Language Server separately for .properties/.yml files.
            --   2. Register client-side LSP commands for bidirectional communication.
            -- Consider using a dedicated plugin like spring-boot.nvim or a custom lightweight solution.
            "vscode-spring-boot-tools",
        }

        for _, tool in ipairs(ensure_installed) do
            local package = mason_registry.get_package(tool)
            if not package:is_installed() then
                vim.notify("Installing " .. tool .. "...", vim.log.levels.INFO)
                package:install():once("closed", function()
                    if package:is_installed() then
                        vim.notify(tool .. " installed successfully", vim.log.levels.INFO)
                    else
                        vim.notify("Failed to install " .. tool, vim.log.levels.ERROR)
                    end
                end)
            end
        end
    end,
}
