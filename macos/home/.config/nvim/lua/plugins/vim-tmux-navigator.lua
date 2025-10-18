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
        { "<C-A-h>", "<cmd>TmuxNavigateLeft<cr>" },
        { "<C-A-j>", "<cmd>TmuxNavigateDown<cr>" },
        { "<C-A-k>", "<cmd>TmuxNavigateUp<cr>" },
        { "<C-A-l>", "<cmd>TmuxNavigateRight<cr>" },
        { "<C-A-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
    },
}
