---@type vim.lsp.Config
return {
    settings = {
        bashIde = {
            -- Do not scan entire home or higher directories for files.
            -- Limit the file scan to only current directory (no nested directories) unless in a more specific directory.
            globPattern = vim.env.GLOB_PATTERN or (function()
                local cwd = vim.fn.getcwd()
                local home = vim.fn.expand("~")

                -- Check if current directory is at or above home directory level
                -- This means cwd is home or a parent of home
                if cwd == home or vim.startswith(home, cwd .. "/") then
                    return "*@(.sh|.inc|.bash|.command)"
                else
                    return "**/*@(.sh|.inc|.bash|.command)"
                end
            end)(),
            includeAllWorkspaceSymbols = true, -- TODO: Make this project-specific once `neoconf` starts working again.
            shfmt = {
                caseIndent = true,
                simplifyCode = true,
            },
        },
    },
}
