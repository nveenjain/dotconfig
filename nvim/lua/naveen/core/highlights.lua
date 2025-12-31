---@module naveen.core.highlights
---@description Centralized highlight and color definitions
---@author Naveen

local M = {}

-- Color palette - semantic colors for consistency
M.colors = {
    -- Git status colors
    git = {
        added = "#98c379",      -- Green for added
        modified = "#e5c07b",   -- Yellow for modified
        deleted = "#e06c75",    -- Red for deleted
        untracked = "#56b6c2",  -- Cyan for untracked
        conflict = "#e06c75",   -- Red for conflicts
    },

    -- Notification colors
    notify = {
        bg = "#2a2a3e",         -- Notification background
        error = "#db4b4b",      -- Error color
        warn = "#e0af68",       -- Warning color
        info = "#0db9d7",       -- Info color
        debug = "#8B8B8B",      -- Debug color
        trace = "#bb9af7",      -- Trace color
        text = "#c0caf5",       -- Body text color
        title = "#7aa2f7",      -- Title color
        border = "#565f89",     -- Border color
    },

    -- Operator/symbol colors (high contrast)
    operators = {
        operator = "#87ff00",       -- Bright green
        delimiter = "#ff9e3b",      -- Orange
        bracket = "#7fb4ca",        -- Blue
        punct_delim = "#ffa066",    -- Light orange
        punct_special = "#ff5d62",  -- Red
    },

    -- UI colors
    ui = {
        color_column = "#3a3a3a",
    },

    -- Gitsigns colors (bright variants)
    gitsigns = {
        add = "#00ff00",        -- Bright green
        change = "#ffff00",     -- Bright yellow
        delete = "#ff0000",     -- Bright red
        topdelete = "#ff0000",
        changedelete = "#ff8800",
        untracked = "#808080",  -- Gray
    },
}

--- Set up transparency highlights (removes backgrounds)
function M.setup_transparency()
    local transparent_groups = {
        "Normal", "NormalFloat", "SignColumn", "EndOfBuffer",
        "LineNr", "Folded", "NonText", "SpecialKey",
        "VertSplit", "WinSeparator", "StatusLine", "StatusLineNC",
    }

    for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
    end

    -- ColorColumn needs a visible but subtle background
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = M.colors.ui.color_column })
end

--- Set up high-contrast operator highlights
function M.setup_operators()
    local c = M.colors.operators

    vim.api.nvim_set_hl(0, "Operator", { fg = c.operator, bold = true })
    vim.api.nvim_set_hl(0, "Delimiter", { fg = c.delimiter, bold = true })
    vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = c.bracket, bold = true })
    vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = c.punct_delim, bold = true })
    vim.api.nvim_set_hl(0, "@punctuation.special", { fg = c.punct_special, bold = true })
    vim.api.nvim_set_hl(0, "@operator", { fg = c.operator, bold = true })
end

--- Set up notification highlights (nvim-notify and snacks.nvim)
function M.setup_notifications()
    local c = M.colors.notify
    local bg = c.bg

    -- nvim-notify groups
    local notify_levels = { "ERROR", "WARN", "INFO", "DEBUG", "TRACE" }
    local level_colors = {
        ERROR = c.error,
        WARN = c.warn,
        INFO = c.info,
        DEBUG = c.debug,
        TRACE = c.trace,
    }

    vim.api.nvim_set_hl(0, "NotifyBackground", { bg = bg })

    for _, level in ipairs(notify_levels) do
        local color = level_colors[level]
        vim.api.nvim_set_hl(0, "Notify" .. level .. "Border", { bg = bg, fg = color })
        vim.api.nvim_set_hl(0, "Notify" .. level .. "Icon", { bg = bg, fg = color })
        vim.api.nvim_set_hl(0, "Notify" .. level .. "Title", { bg = bg, fg = color })
        vim.api.nvim_set_hl(0, "Notify" .. level .. "Body", { bg = bg, fg = c.text })
    end

    -- Snacks.nvim notification groups
    vim.api.nvim_set_hl(0, "SnacksNotifierInfo", { bg = bg, fg = c.info })
    vim.api.nvim_set_hl(0, "SnacksNotifierWarn", { bg = bg, fg = c.warn })
    vim.api.nvim_set_hl(0, "SnacksNotifierError", { bg = bg, fg = c.error })
    vim.api.nvim_set_hl(0, "SnacksNotifierDebug", { bg = bg, fg = c.debug })
    vim.api.nvim_set_hl(0, "SnacksNotifierTrace", { bg = bg, fg = c.trace })
    vim.api.nvim_set_hl(0, "SnacksNotifier", { bg = bg, fg = c.text })
    vim.api.nvim_set_hl(0, "SnacksNotifierTitle", { bg = bg, fg = c.title })
    vim.api.nvim_set_hl(0, "SnacksNotifierBorder", { bg = bg, fg = c.border })
    vim.api.nvim_set_hl(0, "SnacksNotifierIcon", { bg = bg, fg = c.title })
end

--- Set up gitsigns highlight groups
function M.setup_gitsigns()
    local c = M.colors.gitsigns

    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = c.add })
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = c.change })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = c.delete })
    vim.api.nvim_set_hl(0, "GitSignsTopDelete", { fg = c.topdelete })
    vim.api.nvim_set_hl(0, "GitSignsChangeDelete", { fg = c.changedelete })
    vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = c.untracked })
end

--- Set up neo-tree git status highlights
function M.setup_neotree()
    local c = M.colors.git

    vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = c.added })
    vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = c.modified })
    vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = c.deleted })
    vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = c.untracked })
    vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { fg = c.conflict, bold = true })
    vim.api.nvim_set_hl(0, "NeoTreeGitStaged", { fg = c.added })
    vim.api.nvim_set_hl(0, "NeoTreeGitUnstaged", { fg = c.modified })
end

--- Apply all highlight configurations
--- This is the main entry point, replaces the old BgColor() function
function M.apply_all()
    M.setup_transparency()
    M.setup_operators()
    M.setup_notifications()
    M.setup_gitsigns()
    M.setup_neotree()
end

return M
