---@file dap/output.lua
---@description Per-session output buffer management for multi-session debugging
---@requires dap

local M = {}

-- Session ID -> buffer number mapping
local session_buffers = {}

--- Get or create output buffer for a session
---@param session table DAP session object
---@return number bufnr
local function get_or_create_buffer(session)
    local session_id = session.id
    if session_buffers[session_id] and vim.api.nvim_buf_is_valid(session_buffers[session_id]) then
        return session_buffers[session_id]
    end

    local name = session.config.name or "unnamed"
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, string.format("dap-output://%d-%s", session_id, name))
    vim.bo[buf].filetype = "dap-output"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].modifiable = false
    session_buffers[session_id] = buf
    return buf
end

--- Append output to session's buffer
---@param session table DAP session object
---@param body table Output event body
local function append_output(session, body)
    local buf = get_or_create_buffer(session)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    local output = body.output or ""
    if output == "" then
        return
    end

    -- Split output into lines, handling various line endings
    local lines = vim.split(output, "\n", { plain = true })

    -- Remove trailing empty line if output ended with newline
    if #lines > 0 and lines[#lines] == "" then
        table.remove(lines)
    end

    if #lines == 0 then
        return
    end

    vim.bo[buf].modifiable = true
    local line_count = vim.api.nvim_buf_line_count(buf)

    -- If buffer is empty (just created), replace first line; otherwise append
    if line_count == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "" then
        vim.api.nvim_buf_set_lines(buf, 0, 1, false, lines)
    else
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
    end

    vim.bo[buf].modifiable = false

    -- Auto-scroll any windows displaying this buffer
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
            local new_line_count = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_win_set_cursor(win, { new_line_count, 0 })
        end
    end
end

--- Show output buffer for current/specified session
---@param session? table DAP session (uses focused session if nil)
function M.show_output(session)
    local dap = require("dap")
    session = session or dap.session()
    if not session then
        vim.notify("No active debug session", vim.log.levels.INFO)
        return
    end

    local buf = session_buffers[session.id]
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        vim.notify("No output for session: " .. (session.config.name or "unnamed"), vim.log.levels.INFO)
        return
    end

    -- Check if buffer is already visible
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
            vim.api.nvim_set_current_win(win)
            return
        end
    end

    -- Open in split below
    vim.cmd("belowright split")
    vim.api.nvim_win_set_buf(0, buf)
    vim.cmd("normal! G") -- scroll to bottom
end

--- Clean up buffer when session ends
---@param session table DAP session object
local function cleanup_session(session)
    local buf = session_buffers[session.id]
    if buf and vim.api.nvim_buf_is_valid(buf) then
        -- Close any windows showing this buffer first
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == buf then
                pcall(vim.api.nvim_win_close, win, true)
            end
        end
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
    session_buffers[session.id] = nil
end

--- Set up output listeners
---@param dap table DAP module
function M.setup(dap)
    -- Capture output per session
    dap.listeners.after.event_output["session_output"] = function(session, body)
        append_output(session, body)
    end

    -- Cleanup on session end
    dap.listeners.after.event_terminated["session_output"] = cleanup_session
    dap.listeners.after.event_exited["session_output"] = cleanup_session
end

return M
