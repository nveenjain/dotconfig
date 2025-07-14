return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

        local naveen_Fugitive = vim.api.nvim_create_augroup("naveen_Fugitive", {})

        local autocmd = vim.api.nvim_create_autocmd
        autocmd("BufWinEnter", {
            group = naveen_Fugitive,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = {buffer = bufnr, remap = false}
                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git('push')
                end, opts)

                -- rebase always
                vim.keymap.set("n", "<leader>P", function()
                    vim.cmd.Git({'pull',  '--rebase'})
                end, opts)

                -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                -- needed if i did not set the branch up correctly
                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
            end,
        })

        vim.keymap.set("n", "<leader>gs", vim.cmd.Git);
        
        -- Git worktree keybindings
        local worktree = require("naveen.git-worktree")
        vim.keymap.set("n", "<leader>gwc", worktree.create_worktree, { desc = "Create git worktree" })
        vim.keymap.set("n", "<leader>gwr", worktree.remove_worktree, { desc = "Remove git worktree" })
        vim.keymap.set("n", "<leader>gwl", worktree.list_worktrees, { desc = "List git worktrees" })
        vim.keymap.set("n", "<leader>gws", worktree.set_worktree_directory, { desc = "Set worktree directory" })
        vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>")
        vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>")
    end
}
