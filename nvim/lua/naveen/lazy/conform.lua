return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
        formatters_by_ft = {
            go = { "goimports", "gofumpt", "golines" },
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
                timeout_ms = 3000,
                lsp_fallback = true,
            }
        end,
        formatters = {
            golines = {
                prepend_args = { "-m", "88" },
            },
            black = {
                prepend_args = { "--line-length", "88" },
            },
        },
    },
}
