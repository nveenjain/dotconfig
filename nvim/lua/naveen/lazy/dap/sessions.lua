---@file dap/sessions.lua
---@description Multi-session management for DAP
---@requires dap, dap.ui.widgets

local M = {}

--- Get formatted list of active sessions (sorted by id)
---@return table[] # Array of {id, session, label}
local function get_session_list()
    local dap = require("dap")
    local sessions = dap.sessions()
    local items = {}

    for id, session in pairs(sessions) do
        table.insert(items, {
            id = id,
            session = session,
            label = string.format("[%d] %s", id, session.config.name or "unnamed"),
        })
    end

    -- Sort by session id for consistent ordering
    table.sort(items, function(a, b) return a.id < b.id end)

    return items
end

--- Prompt user to select and switch to a session
function M.switch_picker()
    local dap = require("dap")
    local items = get_session_list()
    local current = dap.session()

    if vim.tbl_isempty(items) then
        vim.notify("No active debug sessions", vim.log.levels.INFO)
        return
    end

    -- Mark current session in the list
    for _, item in ipairs(items) do
        if current and item.session.id == current.id then
            item.label = item.label .. " (current)"
        end
    end

    vim.ui.select(items, {
        prompt = "Switch to session:",
        format_item = function(item) return item.label end,
    }, function(choice)
        if choice then
            dap.set_session(choice.session)
        end
    end)
end

--- Prompt user to select and terminate a specific session
function M.terminate_picker()
    local items = get_session_list()

    if vim.tbl_isempty(items) then
        vim.notify("No active debug sessions", vim.log.levels.INFO)
        return
    end

    vim.ui.select(items, {
        prompt = "Select session to terminate:",
        format_item = function(item) return item.label end,
    }, function(choice)
        if choice then
            choice.session:disconnect({ terminateDebuggee = true })
            local remaining = vim.tbl_count(require("dap").sessions()) - 1
            vim.notify(
                string.format("Terminated: %s (%d remaining)", choice.label, remaining),
                vim.log.levels.INFO
            )
        end
    end)
end

--- Terminate all active debug sessions
function M.terminate_all()
    local dap = require("dap")
    local sessions = dap.sessions()
    local count = vim.tbl_count(sessions)
    if count == 0 then
        vim.notify("No active debug sessions", vim.log.levels.INFO)
        return
    end
    for _, session in pairs(sessions) do
        session:disconnect({ terminateDebuggee = true })
    end
end

--- Start a new debug session (forces new, won't continue existing)
function M.run_new()
    require("dap").continue({ new = true })
end

return M
