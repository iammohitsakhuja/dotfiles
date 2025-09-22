return {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = {
                globals = { "vim", "require" },
            },
            workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file("", true), -- Load entire workspace
            },
            hint = {
                enable = true, -- Enable inlay hints.
            },
            completion = {
                enable = true,
                callSnippet = "Both",
            },
        },
    },
}
