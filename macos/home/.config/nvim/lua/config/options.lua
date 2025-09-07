local opt = vim.opt

-- General
-- Having longer `updatetime` (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
opt.updatetime = 1000 -- Reduce the time after typing stops, to write the swap to disk

-- UI
opt.number = true -- Show line numbers
opt.relativenumber = false -- Can be toggled
opt.cmdheight = 3 -- Increase the height of the command-line. Default is 1.
opt.pumheight = 10 -- Reduce the no. of items suggested by autocomplete/popup menu. Default is 0 which means "use available screen space"
opt.showmode = false -- Don't show mode separately (shown in statusline). Saves vertical space too!
opt.signcolumn = "auto:2-5" -- Reserve space for signs. Min: 2 and Max: 5.
opt.scrolloff = 7
opt.sidescrolloff = 10
opt.virtualedit = "block" -- Allows slightly better selection of text when in Visual Block mode.
opt.inccommand = "split" -- Show preview of incremental commands in a separate preview buffer.
opt.splitbelow = true -- Split new windows below the current one
opt.splitright = true -- Vertical split new windows to the right of the current one

-- Search
opt.ignorecase = true -- Ignore case during search (& some other operations)
opt.smartcase = true -- Allow overriding the `ignorecase` option if uppercase characters are typed into the expression

-- Tabs and indentation
opt.expandtab = true -- Convert tabs to spaces
opt.smarttab = true -- While tabbing when cursor is in leading spaces, use `shiftwidth`
opt.shiftwidth = 4 -- Number of spaces for each indentation level
opt.tabstop = 4 -- Number of spaces/columns a literal tab character visually represents
opt.softtabstop = 4 -- Idk. Need this for consistent tab behavior I guess.
opt.autoindent = true -- Keep auto-indentation. Default is also `true`. Added for brevity.
opt.smartindent = true -- Allow smart-indentation for C-like programs that use `{`.
opt.linebreak = true -- During wrapping, break lines at word boundaries rather than breaking in the middle of a word.

-- Files and buffers
opt.encoding = "utf-8"
opt.fileformats = { "unix", "dos", "mac" }

-- Misc
-- Don't show search count messages, e.g. [1/5] when doing a search. We're showing this information on the status line.
opt.shortmess:append("S")
-- Allows using `Left`, `Right`, `h` and `l` keys to go from one line to next in various modes.
-- `<` and `>` represent these arrow keys in Normal & Visual modes.
-- `[` and `]` represent these arrow keys in Insert & Replace modes.
opt.whichwrap:append("<,>,[,],h,l")

-- Terminal
opt.termguicolors = true

opt.list = true
opt.listchars = { lead = '·', tab = '→ ' }

-- Disable netrw (using nvim-tree instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
