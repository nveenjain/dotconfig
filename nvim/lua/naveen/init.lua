require("naveen.remap")
require("naveen.set")
require("naveen.lsp-file-watcher-fix").setup()
require("naveen.lazy_init")


local augroup = vim.api.nvim_create_augroup
local NaveenJGroup = augroup('NaveenJGroup', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

-- Smart large file mode - immediate syntax, no treesitter
local large_file_threshold = 2 * 1024 * 1024  -- 2MB

autocmd("BufReadPre", {
    group = NaveenJGroup,
    callback = function(args)
        local ok, stats = pcall(vim.loop.fs_stat, args.file)
        if ok and stats and stats.size > large_file_threshold then
            -- Mark as large file BEFORE loading
            vim.b[args.buf].large_file = true

            -- Disable I/O overhead immediately
            vim.bo[args.buf].swapfile = false
            vim.bo[args.buf].undofile = false
            vim.bo[args.buf].undolevels = 100  -- Limited undo (still useful)
        end
    end,
})

autocmd("BufReadPost", {
    group = NaveenJGroup,
    callback = function(args)
        if not vim.b[args.buf].large_file then return end

        local stats_ok, stats = pcall(vim.loop.fs_stat, args.file)
        local size_mb = stats_ok and stats and (stats.size / 1024 / 1024) or 0

        -- Disable visual overhead for fast scrolling
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.spell = false
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false
        vim.opt_local.colorcolumn = ""

        -- Keep vim syntax ON (fast, immediate highlighting)
        -- Disable treesitter (too heavy for large files)
        pcall(vim.treesitter.stop, args.buf)

        vim.notify(string.format("Large file (%.1f MB) - using vim syntax", size_mb), vim.log.levels.INFO)
    end,
})

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
    callback = function()
        if vim.bo.filetype ~= "proto" then
            vim.cmd([[%s/\s\+$//e]])
        end
    end,
})

autocmd('LspAttach', {
    group = NaveenJGroup,
    callback = function(e)
        -- LSP attaches immediately (async/background) - no special handling for large files
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

-- Track previous window for special buffers (quickfix, help, fugitive, etc.)
-- so we can return to it when closing
local special_filetypes = { "qf", "help", "fugitive", "man", "lspinfo", "spectre_panel" }

autocmd("BufWinEnter", {
    group = NaveenJGroup,
    callback = function()
        local ft = vim.bo.filetype
        for _, special_ft in ipairs(special_filetypes) do
            if ft == special_ft then
                -- Store the previous window (the one we came from)
                local prev_win = vim.fn.win_getid(vim.fn.winnr('#'))
                if prev_win ~= 0 and vim.api.nvim_win_is_valid(prev_win) then
                    vim.w.source_win = prev_win
                    -- Also update global nav history so C-w navigation works
                    _G.win_nav_history = _G.win_nav_history or {}
                    _G.win_nav_history.prev_win = prev_win
                    -- Determine direction based on window position
                    local current_row = vim.fn.win_screenpos(0)[1]
                    local prev_row = vim.fn.win_screenpos(vim.fn.win_id2win(prev_win))[1]
                    _G.win_nav_history.last_dir = current_row > prev_row and 'j' or 'k'
                end
                return
            end
        end
    end,
})


-- Auto-load DAP on startup if project has .nvim-dap.lua
-- This triggers lazy loading early so project configs work
autocmd("VimEnter", {
    group = NaveenJGroup,
    callback = function()
        vim.defer_fn(function()
            local dap_config = vim.fn.getcwd() .. "/.nvim-dap.lua"
            if vim.fn.filereadable(dap_config) == 1 then
                -- Trigger DAP lazy loading, which loads project config
                require('dap')
            end
        end, 50)
    end,
})

