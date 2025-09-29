---@brief
---
--- https://github.com/dart-lang/sdk/tree/master/pkg/analysis_server/tool/lsp_spec
---
--- Language server for dart.

---@type vim.lsp.Config
return {
    cmd = { "dart", "language-server", "--protocol=lsp" },
    filetypes = { "dart" },
    root_markers = { "pubspec.yaml" },
    init_options = {
        onlyAnalyzeProjectsWithOpenFiles = false,
        suggestFromUnimportedLibraries = true,
        closingLabels = false,
        outline = true,
        flutterOutline = true,
        allowOpenUri = false,
    },
    settings = {
        dart = {
            analysisExcludedFolders = {},
            enableSdkFormatter = true,
            completeFunctionCalls = true,
            showTodos = true,
            renameFilesWithClasses = "never",
            enableSnippets = true,
            updateImportsOnRename = true,
            documentation = "full",
            includeDependenciesInWorkspaceSymbols = true,
            inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                returnTypes = { enabled = true },
                typeArguments = { enabled = true },
                variableTypes = { enabled = true },
            },
        },
    },
}
