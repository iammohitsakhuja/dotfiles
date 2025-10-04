-- Command to manually invoke formatting via Conform
vim.api.nvim_create_user_command("ConformFormat", function(args)
    local format_type = args.args ~= "" and args.args or "normal"

    -- Configure format options based on type
    local format_opts = {}
    if format_type == "injected" then
        format_opts.formatters = { "injected" }
        format_opts.timeout_ms = 3000
    else
        format_opts.async = true
    end

    require("conform").format(format_opts)
end, {
    range = true,
    nargs = "?",
    complete = function()
        return { "normal", "injected" }
    end,
})

-- Command to toggle auto-formatting for the entire session or the current buffer.
vim.api.nvim_create_user_command("ConformFormatToggle", function(args)
    local scope, current_state, new_state

    if args.bang then
        -- ConformFormatToggle! will toggle auto-formatting for the entire session.
        scope = "session"
        current_state = vim.g.disable_autoformat or false
        new_state = not current_state
        vim.g.disable_autoformat = new_state
    else
        scope = "buffer"
        current_state = vim.b.disable_autoformat or false
        new_state = not current_state
        vim.b.disable_autoformat = new_state
    end

    local status = new_state and "disabled" or "enabled"
    vim.notify("Auto-format " .. status .. " for " .. scope, vim.log.levels.INFO)
end, {
    desc = "Toggle autoformat-on-save",
    bang = true,
})
