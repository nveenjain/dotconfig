---@module naveen.core.performance
---@description Performance utilities for handling large operations
---@author Naveen

local M = {}

-- Auto-close unused buffers after 30 mins of inactivity
-- Prevents memory bloat from accumulated hidden buffers
local buffer_timers = {}

local function setup_buffer_cleanup()
  vim.api.nvim_create_autocmd("BufLeave", {
    group = vim.api.nvim_create_augroup("NavBufferCleanup", { clear = true }),
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()

      -- Cancel existing timer for this buffer if any
      if buffer_timers[bufnr] then
        buffer_timers[bufnr]:stop()
      end

      -- Set timer to delete buffer after 30 minutes
      buffer_timers[bufnr] = vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr)
           and not vim.bo[bufnr].modified
           and vim.fn.bufwinnr(bufnr) == -1 then
          pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        end
        buffer_timers[bufnr] = nil
      end, 1800000) -- 30 minutes in ms
    end
  })

  -- Cancel timer when buffer is re-entered
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("NavBufferCleanupCancel", { clear = true }),
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if buffer_timers[bufnr] then
        buffer_timers[bufnr]:stop()
        buffer_timers[bufnr] = nil
      end
    end
  })
end

-- Initialize buffer cleanup on startup
vim.schedule(setup_buffer_cleanup)

M.turbo_mode = false
M.original_settings = {}

--- Enter turbo mode - disables expensive features for fast bulk operations
function M.enter_turbo_mode()
    if M.turbo_mode then return end
    M.turbo_mode = true

    local buf = vim.api.nvim_get_current_buf()

    M.original_settings = {
        eventignore = vim.o.eventignore,
        undolevels = vim.bo[buf].undolevels,
    }

    -- Suppress events that trigger expensive recomputation
    vim.o.eventignore = "TextChanged,TextChangedI,TextChangedP,CursorMoved,CursorMovedI"
    vim.bo[buf].undolevels = -1

    -- Disable treesitter and diagnostics
    pcall(vim.treesitter.stop, buf)
    vim.diagnostic.enable(false, { bufnr = buf })
end

--- Exit turbo mode - restores normal settings
function M.exit_turbo_mode()
    if not M.turbo_mode then return end

    local buf = vim.api.nvim_get_current_buf()

    -- Restore settings
    vim.o.eventignore = M.original_settings.eventignore or ""
    vim.bo[buf].undolevels = M.original_settings.undolevels or 1000

    -- Re-enable treesitter (deferred to avoid blocking)
    vim.schedule(function()
        pcall(vim.treesitter.start, buf)
    end)

    -- Re-enable diagnostics
    vim.diagnostic.enable(true, { bufnr = buf })

    M.turbo_mode = false
    M.original_settings = {}
end

--- Perform a paste operation in turbo mode
---@param paste_cmd string The paste command (e.g., '"+p' or '"+P')
function M.turbo_paste(paste_cmd)
    M.enter_turbo_mode()
    vim.cmd("normal! " .. paste_cmd)
    vim.defer_fn(function()
        M.exit_turbo_mode()
    end, 50)
end

return M
