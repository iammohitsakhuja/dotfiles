-- Base config taken from `neovim/nvim-lspconfig`

---@type vim.lsp.Config
return {
    cmd = { "dart", "language-server", "--protocol=lsp" },
    filetypes = { "dart" },
    root_markers = { "pubspec.yaml" },
    init_options = {
        onlyAnalyzeProjectsWithOpenFiles = false,
        suggestFromUnimportedLibraries = true,
        closingLabels = true,
        outline = true,
        flutterOutline = true,
        allowOpenUri = false,
    },
    settings = {
        dart = {
            completeFunctionCalls = true,
            showTodos = true,
        },
    },
}
