-- Base config taken from `neovim/nvim-lspconfig`

---@type vim.lsp.Config
return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
    root_markers = { ".git" },
    settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
            format = { enable = true },
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/github-action.json"] = "/action.yml",
            },
        },
    },
    on_init = function(client)
        client.server_capabilities.documentFormattingProvider = true
    end,
}
