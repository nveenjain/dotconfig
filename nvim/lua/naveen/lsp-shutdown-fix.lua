-- Fix LSP shutdown errors
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        -- Stop all LSP clients gracefully
        local clients = vim.lsp.get_clients()
        for _, client in ipairs(clients) do
            vim.lsp.stop_client(client.id)
        end
    end,
})