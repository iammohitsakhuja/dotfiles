-- Base config taken from `neovim/nvim-lspconfig`

---@type vim.lsp.Config
return {
    cmd = { "protols" },
    filetypes = { "proto" },
    root_markers = { ".git" },
}
