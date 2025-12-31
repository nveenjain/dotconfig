---@module naveen.core.autocmd
---@description Autocommand utilities and standardized group names
---@author Naveen

local M = {}

-- Standardized augroup names (Nav* prefix for consistency)
M.groups = {
    main = "NavMain",           -- Main configuration autocommands
    yank = "NavYankHighlight",  -- Yank highlighting
    fugitive = "NavFugitive",   -- Fugitive buffer handling
    dap = "NavDap",             -- DAP-related autocommands
    lsp = "NavLsp",             -- LSP-related autocommands
}

-- Cache for created groups
local created_groups = {}

--- Create an augroup with standard naming
---@param name string The group name (will use M.groups if exists, otherwise use as-is)
---@param opts table|nil Optional options (default: { clear = true })
---@return integer # The augroup ID
function M.create_group(name, opts)
    local group_name = M.groups[name] or name
    opts = opts or { clear = true }

    local group_id = vim.api.nvim_create_augroup(group_name, opts)
    created_groups[group_name] = group_id

    return group_id
end

--- Get or create an augroup
---@param name string The group name
---@return integer # The augroup ID
function M.get_or_create_group(name)
    local group_name = M.groups[name] or name

    if created_groups[group_name] then
        return created_groups[group_name]
    end

    return M.create_group(name)
end

--- Create an autocommand with error handling
---@param event string|string[] The event(s) to trigger on
---@param opts table The autocommand options
---@return integer|nil # The autocommand ID, or nil on error
function M.create_autocmd(event, opts)
    local ok, result = pcall(vim.api.nvim_create_autocmd, event, opts)
    if not ok then
        vim.notify("Failed to create autocmd: " .. tostring(result), vim.log.levels.ERROR)
        return nil
    end
    return result
end

--- Create a filetype-specific autocommand
---@param ft string|string[] The filetype(s)
---@param callback function The callback function
---@param group string|nil The augroup name (optional)
---@return integer|nil # The autocommand ID
function M.on_filetype(ft, callback, group)
    local pattern = type(ft) == "table" and ft or { ft }

    return M.create_autocmd("FileType", {
        pattern = pattern,
        callback = callback,
        group = group and M.get_or_create_group(group) or nil,
    })
end

--- Create a BufEnter autocommand
---@param pattern string|string[] The pattern(s)
---@param callback function The callback function
---@param group string|nil The augroup name (optional)
---@return integer|nil # The autocommand ID
function M.on_buf_enter(pattern, callback, group)
    return M.create_autocmd("BufEnter", {
        pattern = pattern,
        callback = callback,
        group = group and M.get_or_create_group(group) or nil,
    })
end

--- Create a User event autocommand
---@param pattern string The User event pattern
---@param callback function The callback function
---@param opts table|nil Additional options
---@return integer|nil # The autocommand ID
function M.on_user_event(pattern, callback, opts)
    opts = opts or {}
    return M.create_autocmd("User", vim.tbl_extend("force", {
        pattern = pattern,
        callback = callback,
    }, opts))
end

return M
