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

-- Auto-resize windows
autocmd("VimResized", {
  group = general,
  pattern = "*",
  command = "tabdo wincmd =",
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

-- Markdown fenced languages
vim.g.markdown_fenced_languages = { 'bash=sh', 'c', 'cpp', 'java', 'lua', 'python', 'sql' }
