-- Base config taken from `neovim/nvim-lspconfig`

---@type vim.lsp.Config
return {
    cmd = { "marksman", "server" },
    filetypes = { "markdown", "markdown.mdx" },
    root_markers = { ".marksman.toml", ".git" },
}
