---@module "lazy"
---@type LazySpec
return {
    {
        "milanglacier/minuet-ai.nvim",
        cond = vim.g.ai_mode == "minimal",
        event = { "BufReadPost", "InsertEnter" },
        opts = {
            cmp = {
                enable_auto_complete = false,
            },
            blink = {
                enable_auto_complete = false,
            },
            virtualtext = {
                auto_trigger_ft = { "*" },
                auto_trigger_ignore_ft = { "TelescopePrompt" },
                keymap = {
                    accept = "<M-;>",
                    prev = "<M-[>",
                    next = "<M-]>",
                    dismiss = "<C-]>",
                },
                show_on_completion_menu = false,
            },
            provider = "openai_fim_compatible",
            n_completions = 1,
            context_window = 4096,
            provider_options = {
                openai_fim_compatible = {
                    api_key = "TERM",
                    name = "Ollama",
                    end_point = "http://localhost:11434/v1/completions",
                    model = "qwen2.5-coder:3b",
                    optional = {
                        max_tokens = 128,
                        top_p = 0.9,
                    },
                },
            },
        },
    },

    {
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
                    user = "  " .. user .. " ",
                    assistant = "  Copilot ",
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
    },

    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        build = ":Copilot auth",
        event = { "BufReadPost", "InsertEnter" },
        cond = vim.g.ai_mode == "copilot",
        dependencies = {
            {
                "copilotlsp-nvim/copilot-lsp",
                ---@module "copilot-lsp"
                ---@type copilotlsp.config
                opts = {
                    ---@diagnostic disable-next-line: missing-fields
                    nes = {
                        move_count_threshold = 2, -- Reduce threshold to make it less annoying.
                    },
                },
                init = function()
                    vim.g.copilot_nes_debounce = 500
                    -- vim.lsp.enable("copilot_ls")
                end,
            },
        },
        ---@module "copilot"
        ---@type CopilotConfig
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            ---@diagnostic disable-next-line: missing-fields
            panel = {
                enabled = false,
            },

            ---@diagnostic disable-next-line: missing-fields
            suggestion = {
                enabled = true,
                auto_trigger = true,
                hide_during_completion = true,
                debounce = 250, -- Increase debounce to reduce annoyance of suggestions.
                keymap = {
                    accept = "<M-;>",
                    prev = "<M-[>",
                    next = "<M-]>",
                    dismiss = "<C-]>",
                },
            },

            nes = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept_and_goto = "<leader>p",
                    accept = false,
                    dismiss = "<Esc>",
                },
            },

            filetypes = {
                markdown = true,
            },
        },
    },
}
