---@module naveen.core.constants
---@description Centralized constants and magic numbers for the Neovim configuration
---@author Naveen

local M = {}

-- File size thresholds
M.LARGE_FILE_THRESHOLD = 2 * 1024 * 1024  -- 2MB - files larger than this get special handling

-- Timing constants (in milliseconds)
M.LSP_RESTART_DELAY = 100      -- Delay before restarting LSP
M.DEFER_DELAY = 50             -- General defer delay for async operations
M.YANK_HIGHLIGHT_TIMEOUT = 40  -- Duration of yank highlight
M.DAP_TIMEOUT = 30000          -- Debug adapter timeout (30 seconds)
M.DAP_LOAD_DELAY = 100         -- Delay for loading DAP breakpoints

-- UI constants
M.NEO_TREE_WIDTH = 35          -- Neo-tree sidebar width
M.UNDO_LEVELS_LARGE_FILE = 100 -- Reduced undo levels for large files
M.NEO_TREE_CLOSE_DELAY = 10    -- Delay before closing neo-tree on startup

-- DAP constants
M.DAP_PORT_BASE = 38697        -- Base port for DAP connections
M.DAP_PORT_RANGE = 1000        -- Random range for port selection

-- Special filetypes that need window tracking
M.SPECIAL_FILETYPES = {
    "qf",
    "help",
    "fugitive",
    "man",
    "lspinfo",
    "spectre_panel",
}

-- DAP filetypes (for Copilot integration)
M.DAP_FILETYPES = {
    ["dap-repl"] = true,
    dapui_watches = true,
    dapui_stacks = true,
    dapui_breakpoints = true,
    dapui_scopes = true,
    dapui_console = true,
}

return M
