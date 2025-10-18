---@module "lazy"
---@type LazySpec
return {
    "luukvbaal/statuscol.nvim",
    config = function()
        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
            relculright = true,
            ft_ignore = {
                "dapui_scopes",
                "dapui_breakpoints",
                "dapui_stacks",
                "dapui_watches",
                "dap-repl",
                "dapui_console",
            },
            segments = {
                -- Fold icons without numbers
                { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                -- Separator + Signs
                { text = { " ", "%s" }, click = "v:lua.ScSa" },
                -- Line numbers + separator
                { text = { builtin.lnumfunc, " " }, condition = { true, builtin.not_empty }, click = "v:lua.ScLa" },
            },
        })
    end,
}
