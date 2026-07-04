---@file fidget.lua
---@description LSP progress + notification toasts in the bottom-right.
---  Surfaces gopls/workspace-load errors (e.g. go.work toolchain mismatches)
---  as a clean toast instead of a buried statusline string.

return {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
        progress = {
            display = {
                done_ttl = 3,
                progress_icon = { pattern = "dots", period = 1 },
            },
        },
        notification = {
            override_vim_notify = true,  -- route vim.notify through fidget
            window = {
                winblend = 0,            -- opaque; plays nicer in tmux/ghostty
                border = "none",
            },
        },
    },
}
