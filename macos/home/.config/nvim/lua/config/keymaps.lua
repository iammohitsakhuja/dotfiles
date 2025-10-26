local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better escape
keymap("i", "jk", "<ESC>", opts)

-- Save file
keymap("n", "<leader>w", ":write<CR>", opts)
keymap("n", "<leader>W", ":write!<CR>", opts)

-- Close buffers
keymap("n", "<leader>bd", function()
    MiniBufremove.delete(0)
end, opts)
keymap("n", "<leader>bD", function()
    MiniBufremove.delete(0, true)
end, opts)

-- Clear search highlighting
keymap("n", "<leader>nh", ":nohl<CR>", opts)

-- Move lines up/down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Start of line
keymap("n", "0", "^", opts)

-- Toggle numbers and relative numbers.
keymap("n", "<leader>tn", function()
    vim.opt.number = not vim.opt.number:get()
end, { desc = "Toggle numbers" })

keymap("n", "<leader>trn", function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative numbers" })

-- Better indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
