return {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
        'nvim-lua/plenary.nvim'
    },
    cond = vim.g.vscode == nil,
    cmd = { "Telescope" },
    keys = {
        { '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            require('telescope.builtin').grep_string({ search = word })
        end, desc = "Grep word under cursor" },
        { '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            require('telescope.builtin').grep_string({ search = word })
        end, desc = "Grep WORD under cursor" },
        { '<leader>ps', function()
            require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") })
        end, desc = "Grep with prompt" },
        { '<leader>pg', function() require('telescope.builtin').live_grep() end, desc = "Live Grep" },
        { '<leader>pb', function() require('telescope.builtin').buffers() end, desc = "Buffers" },
        { '<leader>vh', function() require('telescope.builtin').help_tags() end, desc = "Help Tags" },
    },
    config = function()
        local actions = require("telescope.actions")
        require('telescope').setup({
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                },
            },
            pickers = {
                find_files = {
                    find_command = { "fd", "--type", "f" },
                },
                buffers = {
                    mappings = {
                        i = {
                            ["<C-d>"] = actions.delete_buffer,
                        },
                        n = {
                            ["dd"] = actions.delete_buffer,
                        },
                    },
                },
            },
        })
        pcall(require('telescope').load_extension, 'todo-comments')
    end
}
