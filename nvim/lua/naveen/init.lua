---@file init.lua
---@description Main Neovim configuration orchestration
---@author Naveen

-- Load core modules
require("naveen.remap")
require("naveen.set")
require("naveen.lsp-file-watcher-fix").setup()
require("naveen.lazy_init")

-- Import utilities
local core = require("naveen.core")
local constants = core.constants
local autocmd = core.autocmd

-- Create main augroup
local main_group = autocmd.create_group("main")
local yank_group = autocmd.create_group("yank")

--------------------------------------------------------------------------------
-- Large File Handling
--------------------------------------------------------------------------------

-- Detect large files before loading and disable heavy features
vim.api.nvim_create_autocmd("BufReadPre", {
    group = main_group,
    callback = function(args)
        local ok, stats = pcall(vim.loop.fs_stat, args.file)
        if ok and stats and stats.size > constants.LARGE_FILE_THRESHOLD then
            -- Mark as large file BEFORE loading
            vim.b[args.buf].large_file = true

            -- Suppress autocmds during load for faster opening
            vim.b[args.buf].saved_eventignore = vim.o.eventignore
            vim.o.eventignore = "FileType,Syntax,BufEnter,BufWinEnter,WinEnter"

            -- Disable I/O overhead immediately
            vim.bo[args.buf].swapfile = false
            vim.bo[args.buf].undofile = false
            vim.bo[args.buf].undolevels = constants.UNDO_LEVELS_LARGE_FILE

            -- Very large files: mark for syntax disable
            if stats.size > constants.VERY_LARGE_FILE_THRESHOLD then
                vim.b[args.buf].very_large_file = true
            end
        end
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = main_group,
    callback = function(args)
        -- Restore eventignore
        if vim.b[args.buf].saved_eventignore ~= nil then
            vim.o.eventignore = vim.b[args.buf].saved_eventignore
            vim.b[args.buf].saved_eventignore = nil
        end

        if not vim.b[args.buf].large_file then
            return
        end

        local stats_ok, stats = pcall(vim.loop.fs_stat, args.file)
        local size_mb = stats_ok and stats and (stats.size / 1024 / 1024) or 0

        -- Disable visual overhead for fast scrolling
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.spell = false
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false
        vim.opt_local.colorcolumn = ""
        vim.opt_local.synmaxcol = 120

        -- Disable treesitter (too heavy for large files)
        pcall(vim.treesitter.stop, args.buf)

        if vim.b[args.buf].very_large_file then
            -- Very large files: disable syntax entirely
            vim.cmd("syntax off")
            vim.notify(string.format("Very large file (%.1f MB) - syntax disabled", size_mb), vim.log.levels.WARN)
        else
            vim.notify(string.format("Large file (%.1f MB) - using vim syntax", size_mb), vim.log.levels.INFO)
        end
    end,
})

--------------------------------------------------------------------------------
-- Module Reload Helper
--------------------------------------------------------------------------------

--- Reload a Lua module (for development)
--- Global function for easy access from command line
---@param name string Module name to reload
function R(name)
    require("plenary.reload").reload_module(name)
end

--------------------------------------------------------------------------------
-- VSCode Integration
--------------------------------------------------------------------------------

if core.is_vscode then
    require("naveen.cursor")
end

--------------------------------------------------------------------------------
-- Filetype Registration
--------------------------------------------------------------------------------

vim.filetype.add({
    extension = {
        templ = "templ",
    },
})

--------------------------------------------------------------------------------
-- Yank Highlighting
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("TextYankPost", {
    group = yank_group,
    pattern = "*",
    callback = function()
        vim.hl.on_yank({
            higroup = "IncSearch",
            timeout = constants.YANK_HIGHLIGHT_TIMEOUT,
        })
    end,
})

--------------------------------------------------------------------------------
-- User Commands
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command("E", "Explore", {})
vim.api.nvim_create_user_command("Eq", "EditQuery", {})

-- Custom LspRestart to avoid watchfiles error
vim.api.nvim_create_user_command("LspRestart", function()
    local clients = vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
        local attached_buffers = vim.lsp.get_buffers_by_client_id(client.id)
        local ok, err = pcall(vim.lsp.stop_client, client.id)
        if not ok then
            vim.notify("Error stopping LSP client: " .. tostring(err), vim.log.levels.WARN)
        end
        vim.defer_fn(function()
            for _ = 1, #attached_buffers do
                vim.cmd("LspStart")
            end
        end, constants.LSP_RESTART_DELAY)
    end
end, {})

-- Alternative safer LspRestart that just reloads buffer
vim.api.nvim_create_user_command("LspRefresh", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd("edit")
    vim.api.nvim_win_set_cursor(0, cursor)
end, {})

--------------------------------------------------------------------------------
-- Buffer Write Hooks
--------------------------------------------------------------------------------

-- Remove trailing whitespace on save (except for proto files)
vim.api.nvim_create_autocmd("BufWritePre", {
    group = main_group,
    pattern = "*",
    callback = function()
        if vim.bo.filetype ~= "proto" then
            vim.cmd([[%s/\s\+$//e]])
        end
    end,
})

--------------------------------------------------------------------------------
-- Netrw Settings
--------------------------------------------------------------------------------

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 20

--------------------------------------------------------------------------------
-- Special Buffer Window Tracking
--------------------------------------------------------------------------------

-- Track previous window for special buffers (quickfix, help, fugitive, etc.)
-- so we can return to it when closing
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = main_group,
    callback = function()
        local ft = vim.bo.filetype
        for _, special_ft in ipairs(constants.SPECIAL_FILETYPES) do
            if ft == special_ft then
                local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
                if prev_win ~= 0 and vim.api.nvim_win_is_valid(prev_win) then
                    vim.w.source_win = prev_win
                    -- Update global nav history for C-w navigation
                    _G.win_nav_history = _G.win_nav_history or {}
                    _G.win_nav_history.prev_win = prev_win
                    -- Determine direction based on window position
                    local current_row = vim.fn.win_screenpos(0)[1]
                    local prev_row = vim.fn.win_screenpos(vim.fn.win_id2win(prev_win))[1]
                    _G.win_nav_history.last_dir = current_row > prev_row and "j" or "k"
                end
                return
            end
        end
    end,
})

--------------------------------------------------------------------------------
-- DAP Auto-loading
--------------------------------------------------------------------------------

-- Auto-load DAP on startup if project has .nvim-dap.lua
vim.api.nvim_create_autocmd("VimEnter", {
    group = main_group,
    callback = function()
        vim.defer_fn(function()
            local dap_config = vim.fn.getcwd() .. "/.nvim-dap.lua"
            if vim.fn.filereadable(dap_config) == 1 then
                require("dap")
            end
        end, constants.DEFER_DELAY)
    end,
})
