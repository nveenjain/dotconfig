---@module naveen.core
---@description Core utilities module - re-exports all utility modules
---@author Naveen

local M = {}

-- Re-export all modules for convenient access
-- Usage: local core = require("naveen.core")
--        core.git.get_git_root()
--        core.not_vscode()

M.constants = require("naveen.core.constants")
M.vscode = require("naveen.core.vscode")
M.git = require("naveen.core.git")
M.env = require("naveen.core.env")
M.autocmd = require("naveen.core.autocmd")
M.highlights = require("naveen.core.highlights")
M.performance = require("naveen.core.performance")

-- Convenience re-exports for common operations
-- These can be accessed directly: core.not_vscode() instead of core.vscode.not_vscode()

--- Check if NOT in VSCode (for lazy.nvim cond)
M.not_vscode = M.vscode.not_vscode

--- Check if in VSCode
M.is_vscode = M.vscode.is_vscode

--- Get git root directory
M.get_git_root = M.git.get_git_root

--- Check if in a git repo
M.is_git_repo = M.git.is_git_repo

--- Get project root (git root or cwd)
M.get_project_root = M.git.get_project_root

return M
