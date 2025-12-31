---@file fugitive.lua
---@description Git integration with vim-fugitive
---@requires naveen.core.autocmd

local autocmd = require("naveen.core.autocmd")

return {
    "tpope/vim-fugitive",
    keys = {
        {
            "<leader>gs",
            function()
                -- Check if a fugitive buffer is visible in any window
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == "fugitive" then
                        vim.api.nvim_win_close(win, false)
                        return
                    end
                end
                -- Track source window for navigation history
                local current_win = vim.api.nvim_get_current_win()
                -- No fugitive window found, open one
                vim.cmd("Git")
                -- Update global nav history so C-w k returns to source
                _G.win_nav_history = _G.win_nav_history or {}
                _G.win_nav_history.prev_win = current_win
                _G.win_nav_history.last_dir = "j"
            end,
            desc = "Git: Toggle status",
        },
    },
    config = function()
        local fugitive_group = autocmd.create_group("fugitive")

        vim.api.nvim_create_autocmd("BufWinEnter", {
            group = fugitive_group,
            pattern = "*",
            callback = function()
                if vim.bo.filetype ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git("push")
                end, vim.tbl_extend("force", opts, { desc = "Git: Push" }))

                vim.keymap.set("n", "<leader>P", function()
                    vim.cmd.Git({ "pull", "--rebase" })
                end, vim.tbl_extend("force", opts, { desc = "Git: Pull --rebase" }))

                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", vim.tbl_extend("force", opts, { desc = "Git: Push upstream" }))
            end,
        })

        -- Git branch creation
        vim.keymap.set("n", "<leader>gb", function()
            vim.ui.input({ prompt = "New branch name: " }, function(branch_name)
                if branch_name and branch_name ~= "" then
                    vim.cmd("Git checkout -b " .. branch_name)
                end
            end)
        end, { desc = "Git: Create branch" })

        -- Git worktree keybindings
        local worktree = require("naveen.git-worktree")
        vim.keymap.set("n", "<leader>gwc", worktree.create_worktree, { desc = "Git: Create worktree" })
        vim.keymap.set("n", "<leader>gwr", worktree.remove_worktree, { desc = "Git: Remove worktree" })
        vim.keymap.set("n", "<leader>gwl", worktree.list_worktrees, { desc = "Git: List worktrees" })
        vim.keymap.set("n", "<leader>gws", worktree.set_worktree_directory, { desc = "Git: Set worktree dir" })

        -- Diff keymaps
        vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>", { desc = "Git: Get from left" })
        vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>", { desc = "Git: Get from right" })
    end,
}
