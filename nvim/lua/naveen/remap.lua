vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Vex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux new tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- Git navigation
vim.keymap.set('n', ']g', ':Gitsigns next_hunk<CR>', { silent = true, desc = 'Next git hunk' })
vim.keymap.set('n', '[g', ':Gitsigns prev_hunk<CR>', { silent = true, desc = 'Previous git hunk' })
vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { silent = true, desc = 'Preview git hunk' })
vim.keymap.set('n', '<leader>gh', ':Gitsigns stage_hunk<CR>', { silent = true, desc = 'Stage git hunk' })
vim.keymap.set('n', '<leader>gr', ':Gitsigns reset_hunk<CR>', { silent = true, desc = 'Reset git hunk' })
vim.keymap.set('n', '<leader>gb', ':Gitsigns blame_line<CR>', { silent = true, desc = 'Git blame line' })
vim.keymap.set('n', '<leader>gd', ':Gitsigns diffthis<CR>', { silent = true, desc = 'Git diff this' })

-- Window management
vim.keymap.set('n', '<C-w>v', function()
    vim.cmd('vsplit')
    vim.cmd('wincmd l')
end, { desc = 'Split vertically and move to new split' })
vim.keymap.set('n', '<C-w>s', function()
    vim.cmd('split')
    vim.cmd('wincmd j')
end, { desc = 'Split horizontally and move to new split' })

-- Fugitive shortcuts
vim.keymap.set('n', '<leader>gc', ':Git checkout ', { desc = 'Git checkout branch' })
vim.keymap.set('n', '<leader>gB', ':Git branch<CR>', { desc = 'List git branches' })
vim.keymap.set('n', '<leader>gm', ':Git checkout main<CR>', { desc = 'Checkout main branch' })
vim.keymap.set('n', '<leader>gM', ':Git checkout master<CR>', { desc = 'Checkout master branch' })

-- Window maximize toggle
vim.keymap.set('n', '<leader>m', function()
    local win = vim.api.nvim_get_current_win()
    local is_maximized = vim.t.maximized_window == win
    
    if is_maximized then
        -- Restore windows
        vim.cmd('wincmd =')
        vim.t.maximized_window = nil
    else
        -- Maximize current window
        vim.cmd('wincmd |')
        vim.cmd('wincmd _')
        vim.t.maximized_window = win
    end
end, { desc = 'Toggle window maximize' })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
