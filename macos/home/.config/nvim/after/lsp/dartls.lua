---@brief
---
--- https://github.com/dart-lang/sdk/tree/master/pkg/analysis_server/tool/lsp_spec
---
--- Language server for dart.

---@type vim.lsp.Config
return {
    init_options = {
        onlyAnalyzeProjectsWithOpenFiles = false,
        allowOpenUri = false,
    },
}
