return {
    settings = {
        java = {
            signatureHelp = { enabled = true },
            completion = { enabled = true },
            sources = {
                organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
            },
            symbols = {
                includeSourceMethodDeclarations = true,
            },
        },
    },
}
