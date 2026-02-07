return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
        formatters_by_ft = {
            go = { "golines", "gci" },  -- golines formats + wraps; gci runs LAST to fix import order
            python = { "black" },
            json = { "prettier" },
        },
        format_on_save = function(bufnr)
            -- Disable format on save for proto files
            local filetype = vim.bo[bufnr].filetype
            if filetype == "proto" then
                return nil
            end
            return {
                timeout_ms = 5000,
                lsp_fallback = true,
            }
        end,
        formatters = {
            gci = {
                args = function()
                    local result = { "write", "--skip-generated", "--skip-vendor", "--custom-order",
                        "--section", "standard" }
                    -- Detect local module from go.mod for import grouping
                    local gomod = vim.fn.findfile("go.mod", ".;")
                    if gomod ~= "" then
                        local lines = vim.fn.readfile(gomod, "", 1)
                        if lines[1] then
                            local module = lines[1]:match("^module%s+(%S+)")
                            if module then
                                vim.list_extend(result, { "--section", "prefix(" .. module .. ")" })
                            end
                        end
                    end
                    vim.list_extend(result, { "--section", "default", "--section", "blank", "$FILENAME" })
                    return result
                end,
            },
            golines = {
                prepend_args = { "-m", "88" },
            },
            black = {
                prepend_args = { "--line-length", "88" },
            },
        },
    },
}
