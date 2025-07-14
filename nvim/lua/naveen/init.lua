require("naveen.remap")
require("naveen.set")
require("naveen.lsp-file-watcher-fix").setup()
require("naveen.lsp-shutdown-fix")
require("naveen.lazy_init")


local augroup = vim.api.nvim_create_augroup
local NaveenJGroup = augroup('NaveenJGroup', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

if vim.g.vscode then
    require "naveen.cursor"
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

vim.api.nvim_create_user_command('E', 'Explore', {})
vim.api.nvim_create_user_command('Eq', 'EditQuery', {})

autocmd({ "BufWritePre" }, {
    group = NaveenJGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        -- Get the first attached LSP client to determine position encoding
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local client = clients[1]
        if not client then return end
        
        local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
        params.context = { only = { "source.organizeImports" } }
        -- buf_request_sync defaults to a 1000ms timeout. Depending on your
        -- machine and codebase, you may want longer. Add an additional
        -- argument after params if you find that you have to write the file
        -- twice for changes to be saved.
        -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
        for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
            end
        end
        vim.lsp.buf.format({ async = false })
        
        -- Run golines on the current buffer
        local fileName = vim.fn.expand("%")
        local cmd = string.format("golines -w -m 88 %s", fileName)
        vim.fn.system(cmd)
        -- Reload the buffer to reflect golines changes
        vim.cmd("edit!")
    end
})

autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function()
        -- Only try LSP format if there's an active LSP client
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
            vim.lsp.buf.format({ async = false })
        end
        
        -- Run black on the current buffer
        local fileName = vim.fn.expand("%")
        local cmd = string.format("black --line-length 88 --quiet %s", vim.fn.shellescape(fileName))
        vim.fn.system(cmd)
        -- Reload the buffer to reflect black changes
        vim.cmd("edit!")
    end
})

autocmd('LspAttach', {
    group = NaveenJGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("v", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vi", function() vim.lsp.buf.implementation() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)

        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 20
