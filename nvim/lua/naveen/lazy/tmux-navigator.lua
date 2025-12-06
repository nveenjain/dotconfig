-- Window navigation history (shared state)
_G.win_nav_history = _G.win_nav_history or {}

local function nav_with_history(direction, tmux_cmd)
    local current_win = vim.api.nvim_get_current_win()
    local opposite = { h = 'l', j = 'k', k = 'j', l = 'h' }

    -- Check if we should go back to previous window
    if _G.win_nav_history.prev_win
        and _G.win_nav_history.last_dir
        and opposite[_G.win_nav_history.last_dir] == direction
        and vim.api.nvim_win_is_valid(_G.win_nav_history.prev_win) then
        vim.api.nvim_set_current_win(_G.win_nav_history.prev_win)
        _G.win_nav_history.prev_win = current_win
        _G.win_nav_history.last_dir = direction
        return
    end

    -- Use tmux navigator for the actual navigation
    vim.cmd(tmux_cmd)
    local new_win = vim.api.nvim_get_current_win()

    -- Only update history if we actually moved
    if new_win ~= current_win then
        _G.win_nav_history.prev_win = current_win
        _G.win_nav_history.last_dir = direction
    end
end

return {
    'christoomey/vim-tmux-navigator',
    init = function()
        vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
        { "<C-w>h", function() nav_with_history('h', 'TmuxNavigateLeft') end, desc = "Window left (with history)" },
        { "<C-w>j", function() nav_with_history('j', 'TmuxNavigateDown') end, desc = "Window down (with history)" },
        { "<C-w>k", function() nav_with_history('k', 'TmuxNavigateUp') end, desc = "Window up (with history)" },
        { "<C-w>l", function() nav_with_history('l', 'TmuxNavigateRight') end, desc = "Window right (with history)" },
    },
}
