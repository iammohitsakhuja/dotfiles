-- Base config taken from `neovim/nvim-lspconfig`

---@type vim.lsp.Config
return {
    cmd = { "intelephense", "--stdio" },
    filetypes = { "php" },
    root_markers = { ".git", "composer.json" },
    settings = {
        intelephense = {
            files = {
                maxSize = 2000000, -- ~2MB
            },
            completion = {
                fullyQualifyGlobalConstantsAndFunctions = true,
            },
            codeLens = {
                references = {
                    enable = true,
                },
                implementations = {
                    enable = true,
                },
                usages = {
                    enable = true,
                },
                overrides = {
                    enable = true,
                },
                parent = {
                    enable = true,
                },
            },
            maxMemory = 1024,
        },
    },
}
