---@module "lazy"
---@type LazySpec
return {
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
            auto_trigger_ignore_ft = {
                "dapui_scopes",
                "dapui_breakpoints",
                "dapui_stacks",
                "dapui_watches",
                "dap-repl",
                "dapui_console",
                "TelescopePrompt",
            },
            keymap = {
                accept = "<M-;>",
                accept_line = "<M-l>",
                prev = "<M-[>",
                next = "<M-]>",
                dismiss = "<M-e>",
            },
            show_on_completion_menu = false,
        },
        provider = "openai_fim_compatible",
        n_completions = 1,
        context_window = 8192, -- Context window is in characters. The number of tokens is ~25% of that.
        request_timeout = 4,
        provider_options = {
            openai_fim_compatible = {
                api_key = "TERM",
                name = "Ollama",
                end_point = "http://localhost:11434/v1/completions",
                model = "qwen2.5-coder:3b",
                optional = {
                    -- OpenAI-compatible officially supported options by Ollama.
                    -- More details here: https://docs.ollama.com/openai
                    max_tokens = 128, -- limit completion length (speed + control)
                    temperature = 0.1, -- low randomness → more deterministic
                    top_p = 0.9, -- standard nucleus sampling
                    stop = { "\n\n", "\n\n\n" }, -- stop at reasonable block ends
                    seed = 42, -- reproducibility
                    presence_penalty = 0.0, -- not needed for code
                    frequency_penalty = 0.0, -- not needed for code
                    -- Not officially supported, but we're still passing them as they may get used by Ollama IF it
                    -- chooses to pass them along to the underlying model.
                    top_k = 40, -- balances diversity vs determinism
                    repeat_penalty = 1.1, -- reduce duplicate lines/tokens
                },
            },
        },
    },
}
