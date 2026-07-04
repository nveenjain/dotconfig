return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
        formatters_by_ft = {
            go = { "golines" },  -- golines wraps long lines (+gofumpt); imports via gopls organizeImports (lsp.lua)
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
                timeout_ms = 2000,
                lsp_format = "never",
            }
        end,
        formatters = {
            golines = {
                prepend_args = { "-m", "88", "--base-formatter", "gofumpt" },
            },
            black = {
                prepend_args = { "--line-length", "88" },
            },
        },
    },
}
