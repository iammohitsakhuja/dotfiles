-- Define custom autocmds.
-- Many of these are either taken from or inspired by LazyVim: https://github.com/LazyVim/LazyVim

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General autocommands
local general = augroup("General", { clear = true })

-- Highlight yanked text
autocmd("TextYankPost", {
    group = general,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
})

-- Close certain windows with 'q'
autocmd("FileType", {
    group = general,
    pattern = { "help", "lspinfo", "man", "qf", "query", "notify" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", ":close<CR>", { buffer = event.buf, silent = true })
    end,
})

-- Auto-resize windows & splits.
autocmd("VimResized", {
    group = general,
    pattern = "*",
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- Go to last location when opening a buffer.
autocmd("BufReadPost", {
    group = general,
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
    group = general,
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- LspAttach autocmd for additional keymaps not covered by defaults
autocmd("LspAttach", {
    group = general,
    desc = "LSP actions",
    callback = function(event)
        local opts = { buffer = event.buf, noremap = true, silent = true }

        -- Essential keymaps missing from Neovim 0.11 defaults
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist,
            vim.tbl_extend("force", opts, { desc = "Open diagnostics in location list" }))
        vim.keymap.set("n", "<leader>Q", vim.diagnostic.setqflist,
            vim.tbl_extend("force", opts, { desc = "Open diagnostics in quickfix list" }))
    end,
})

-- Markdown fenced languages
vim.g.markdown_fenced_languages = { 'bash=sh', 'c', 'cpp', 'java', 'lua', 'python', 'sql' }
