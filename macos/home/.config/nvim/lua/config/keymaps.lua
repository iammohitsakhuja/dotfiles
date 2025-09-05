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

-- Telescope Keymaps.
local builtin = require("telescope.builtin")
keymap("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
keymap("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" } )
keymap("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
keymap("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
keymap("n", "<leader>fo", builtin.oldfiles, { desc = "Telescope list old files" })
keymap("n", "<leader>fc", builtin.commands, { desc = "Telescope list available plugin/user commands" })
keymap("n", "<leader>fm", builtin.man_pages, { desc = "Telescope list manpages" })
keymap("n", "<leader>fr", builtin.registers, { desc = "Telescope list vim registers" })
keymap("n", "<leader>fk", builtin.keymaps, { desc = "Telescope list keymaps" })
keymap("n", "<leader>flr", builtin.lsp_references, { desc = "Telescope list LSP references" })
keymap("n", "<leader>fli", builtin.lsp_implementations, { desc = "Telescope goto LSP implementation" })
keymap("n", "<leader>fld", builtin.lsp_definitions, { desc = "Telescope goto LSP defintion" })
