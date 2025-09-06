local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better escape
keymap("i", "jk", "<ESC>", opts)

-- Save file
keymap("n", "<leader>s", ":w!<CR>", opts)

-- Window navigation
keymap("n", "<leader>t", "<C-w>w", opts)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Buffer navigation
keymap("n", "<leader>n", ":bnext<CR>", opts)
keymap("n", "<leader>p", ":bprevious<CR>", opts)
keymap("n", "<leader>bd", ":bdelete<CR>", opts)

-- Clear search highlighting
keymap("n", "<leader>l", ":nohl<CR>", opts)

-- Move lines up/down
keymap("n", "<C-j>", ":m .+1<CR>==", opts)
keymap("n", "<C-k>", ":m .-2<CR>==", opts)
keymap("v", "<C-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<C-k>", ":m '<-2<CR>gv=gv", opts)

-- Start of line
keymap("n", "0", "^", opts)

-- Toggle relative numbers
keymap(
  "n",
  "<leader>nt",
  function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
  end,
  { desc = "Toggle relative numbers" }
)

-- Better indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
