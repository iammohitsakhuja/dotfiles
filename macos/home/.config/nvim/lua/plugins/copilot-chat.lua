---@module "lazy"
---@type LazySpec
return {
    "CopilotC-Nvim/CopilotChat.nvim",
    version = "*",
    cmd = "CopilotChat",
    build = "make tiktoken",
    cond = vim.g.ai_mode == "copilot",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = function()
        local user = vim.env.USER or "User"

        ---@module "CopilotChat"
        ---@type CopilotChat.config.Config
        return {
            auto_insert_mode = true,
            window = {
                title = "GitHub Copilot 🤖",
                border = "rounded",
                width = 0.4,
            },
            headers = {
                user = "  " .. user .. " ",
                assistant = "  Copilot ",
            },
        }
    end,
    keys = {
        { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
        { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
        {
            "<leader>at",
            function()
                return require("CopilotChat").toggle()
            end,
            desc = "Toggle (CopilotChat)",
            mode = { "n", "v" },
        },
        {
            "<leader>ax",
            function()
                return require("CopilotChat").reset()
            end,
            desc = "Clear (CopilotChat)",
            mode = { "n", "v" },
        },
        {
            "<leader>aq",
            function()
                vim.ui.input({
                    prompt = "Quick Chat: ",
                }, function(input)
                    if input ~= "" then
                        require("CopilotChat").ask(input)
                    end
                end)
            end,
            desc = "Quick Chat (CopilotChat)",
            mode = { "n", "v" },
        },
        {
            "<leader>ap",
            function()
                require("CopilotChat").select_prompt()
            end,
            desc = "Prompt Actions (CopilotChat)",
            mode = { "n", "v" },
        },
    },
    config = function(_, opts)
        local chat = require("CopilotChat")

        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = "copilot-*",
            callback = function()
                vim.opt_local.relativenumber = false
                vim.opt_local.number = false
                vim.opt_local.conceallevel = 0
            end,
        })

        chat.setup(opts)
    end,
}
