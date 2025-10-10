---@type vim.lsp.Config
return {
    settings = {
        java = {
            signatureHelp = { enabled = true },
            completion = { enabled = true },
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-25",
                        path = "/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home",
                    },
                },
            },
            sources = {
                organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
            },
            symbols = {
                includeSourceMethodDeclarations = true,
            },
        },
    },
}
