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
}
