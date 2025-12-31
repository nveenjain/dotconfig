---@module naveen.core.vscode
---@description VSCode detection and conditional loading utilities
---@author Naveen

local M = {}

--- Check if running inside VSCode
---@return boolean
M.is_vscode = vim.g.vscode ~= nil

--- Condition function for lazy.nvim - returns true when NOT in VSCode
--- Use this in plugin specs: cond = require("naveen.core.vscode").not_vscode
---@return boolean
function M.not_vscode()
    return vim.g.vscode == nil
end

--- Execute a callback only when not in VSCode
---@param callback function The function to execute
function M.when_not_vscode(callback)
    if not M.is_vscode then
        callback()
    end
end

--- Execute a callback only when in VSCode
---@param callback function The function to execute
function M.when_vscode(callback)
    if M.is_vscode then
        callback()
    end
end

return M
