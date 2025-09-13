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
        vim.hl.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

vim.api.nvim_create_user_command('E', 'Explore', {})
vim.api.nvim_create_user_command('Eq', 'EditQuery', {})

-- Custom LspRestart to avoid watchfiles error
vim.api.nvim_create_user_command('LspRestart', function()
    local clients = vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
        local attached_buffers = vim.lsp.get_buffers_by_client_id(client.id)
        -- Wrap stop_client in pcall to handle watchfiles error
        local ok, err = pcall(vim.lsp.stop_client, client.id)
        if not ok then
            vim.notify("Error stopping LSP client: " .. tostring(err), vim.log.levels.WARN)
        end
        vim.defer_fn(function()
            for _, buf in ipairs(attached_buffers) do
                vim.cmd('LspStart')
            end
        end, 100)
    end
end, {})

-- Alternative safer LspRestart that just reloads buffer
vim.api.nvim_create_user_command('LspRefresh', function()
    -- Save current position
    local cursor = vim.api.nvim_win_get_cursor(0)
    -- Reload buffer to re-attach LSP
    vim.cmd('edit')
    -- Restore position
    vim.api.nvim_win_set_cursor(0, cursor)
end, {})

autocmd({ "BufWritePre" }, {
    group = NaveenJGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- Remove formatting from BufWritePre for Go files to allow clean saves
autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        -- Only remove trailing whitespace before save
        vim.cmd([[%s/\s\+$//e]])
    end
})

-- Run formatting and linting after the file is saved
autocmd("BufWritePost", {
    pattern = "*.go",
    callback = function()
        -- Get the first attached LSP client to determine position encoding
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local client = clients[1]
        if not client then return end
        
        -- Save cursor position
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        
        -- Organize imports
        local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
            end
        end
        
        -- Format with LSP
        vim.lsp.buf.format({ async = false })
        
        -- Run golines on the current file
        local fileName = vim.fn.expand("%:p")
        local cmd = string.format("golines -w -m 88 %s", vim.fn.shellescape(fileName))
        vim.fn.system(cmd)
        
        -- Reload the buffer to reflect all changes
        vim.cmd("edit!")
        
        -- Restore cursor position
        vim.api.nvim_win_set_cursor(0, cursor_pos)
    end
})

autocmd("BufWritePost", {
    pattern = "*.py",
    callback = function()
        -- Save cursor position
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        
        -- Only try LSP format if there's an active LSP client
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
            vim.lsp.buf.format({ async = false })
        end
        
        -- Run black on the current buffer
        local fileName = vim.fn.expand("%:p")
        local cmd = string.format("black --line-length 88 --quiet %s", vim.fn.shellescape(fileName))
        vim.fn.system(cmd)
        
        -- Reload the buffer to reflect all changes
        vim.cmd("edit!")
        
        -- Restore cursor position
        vim.api.nvim_win_set_cursor(0, cursor_pos)
    end
})

-- Disable formatting for proto files
autocmd("BufWritePre", {
    pattern = "*.proto",
    callback = function()
        -- Only remove trailing whitespace, no formatting
        vim.cmd([[%s/\s\+$//e]])
    end
})

autocmd('LspAttach', {
    group = NaveenJGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            local client = clients[1]
            if not client then
                vim.notify('No LSP client attached', vim.log.levels.ERROR)
                return
            end
            
            local params = vim.lsp.util.make_position_params(nil, client.offset_encoding)
            vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, config)
                if err then
                    vim.notify('Error when finding definition: ' .. err.message, vim.log.levels.ERROR)
                    return
                end
                
                if not result or vim.tbl_isempty(result) then
                    vim.notify('No definition found', vim.log.levels.INFO)
                    return
                end
                
                -- Convert result to list if it's a single item
                if not vim.islist(result) then
                    result = { result }
                end
                
                -- If only one result, jump directly
                if #result == 1 then
                    vim.lsp.util.show_document(result[1], client.offset_encoding, { reuse_win = true, focus = true })
                else
                    -- Multiple results, use quickfix
                    vim.fn.setqflist({}, ' ', {
                        title = 'LSP definitions',
                        items = vim.lsp.util.locations_to_items(result, client.offset_encoding)
                    })
                    vim.cmd('copen')
                end
            end)
        end, opts)
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

-- Auto-load project-specific DAP configurations
autocmd("VimEnter", {
    group = NaveenJGroup,
    callback = function()
        vim.defer_fn(function()
            -- Only try to load DAP config if DAP is available
            local has_dap = pcall(require, 'dap')
            if not has_dap then
                return
            end
            
            local dap_config = vim.fn.getcwd() .. "/.nvim-dap.lua"
            if vim.fn.filereadable(dap_config) == 1 then
                local ok, err = pcall(dofile, dap_config)
                if not ok then
                    -- Only show error if it's not about missing DAP
                    if not err:match("module 'dap' not found") then
                        vim.notify("Error loading DAP config: " .. tostring(err), vim.log.levels.ERROR)
                    end
                end
            end
        end, 100)
    end,
})

