vim.keymap.set("n", "<leader>vrr", "<cmd>lua require('vscode').action('editor.action.goToReferences')<CR>")
vim.keymap.set("n", "<leader>vi", "<cmd>lua require('vscode').action('editor.action.goToImplementation')<CR>" )
