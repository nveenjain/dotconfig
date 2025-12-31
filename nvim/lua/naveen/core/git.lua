---@module naveen.core.git
---@description Git operations with caching for performance
---@author Naveen

local M = {}

-- Cache for git root to avoid repeated shell calls
local cached_git_root = nil

--- Get the git root directory for the current project
--- Results are cached per session for performance
---@return string|false # The git root path, or false if not in a git repo
function M.get_git_root()
    if cached_git_root == nil then
        local result = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
        if result and vim.v.shell_error == 0 and not result:match("^fatal") then
            cached_git_root = result
        else
            cached_git_root = false
        end
    end
    return cached_git_root
end

--- Check if currently in a git repository
---@return boolean
function M.is_git_repo()
    return M.get_git_root() ~= false
end

--- Get project root (git root or cwd)
---@return string
function M.get_project_root()
    local git_root = M.get_git_root()
    if git_root then
        return git_root
    end
    return vim.fn.getcwd()
end

--- Clear the git root cache (useful when changing directories)
function M.clear_cache()
    cached_git_root = nil
end

--- Execute a git command safely
---@param args string The git command arguments
---@return string|nil # The command output, or nil on error
function M.git_command(args)
    local result = vim.fn.system("git " .. args .. " 2>/dev/null")
    if vim.v.shell_error ~= 0 then
        return nil
    end
    return result
end

return M
