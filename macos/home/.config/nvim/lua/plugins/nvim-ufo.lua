---@module "lazy"
---@type LazySpec
return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
        "luukvbaal/statuscol.nvim",
    },
    event = "BufReadPost",
    opts = {
        provider_selector = function()
            -- Implement fallback for folding. LSP -> Treesitter -> Indent.
            local function customizeSelector(bufnr)
                local function handleFallbackException(err, providerName)
                    if type(err) == "string" and err:match("UfoFallbackException") then
                        return require("ufo").getFolds(bufnr, providerName)
                    else
                        return require("promise").reject(err)
                    end
                end

                return require("ufo")
                    .getFolds(bufnr, "lsp")
                    :catch(function(err)
                        return handleFallbackException(err, "treesitter")
                    end)
                    :catch(function(err)
                        return handleFallbackException(err, "indent")
                    end)
            end

            return customizeSelector
        end,
        preview = {
            mappings = {
                scrollU = "<C-u>",
                scrollD = "<C-d>",
                jumpTop = "gg",
                jumpBot = "G",
            },
        },
    },
    keys = {
        {
            "zR",
            function()
                require("ufo").openAllFolds()
            end,
            desc = "Open all folds",
        },
        {
            "zM",
            function()
                require("ufo").closeAllFolds()
            end,
            desc = "Close all folds",
        },
        {
            "zr",
            function()
                require("ufo").openFoldsExceptKinds()
            end,
            desc = "Fold less",
        },
        {
            "zm",
            function()
                require("ufo").closeFoldsWith()
            end,
            desc = "Fold more",
        },
        {
            "K",
            function()
                -- First, try opening the preview window for the folded lines.
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                -- If no fold exists, then we fallback to showing the `lsp`"s hover window.
                if not winid then
                    vim.lsp.buf.hover()
                end
            end,
            desc = "Peek folded lines",
        },
    },
}
