---@module "lazy"
---@type LazySpec
return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
        "TmuxNavigatorProcessList",
    },
    keys = {
        { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
        { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
        { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
        { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
        { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
    },
}
