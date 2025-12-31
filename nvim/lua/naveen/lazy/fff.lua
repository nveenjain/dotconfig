return {
    {
        "dmtrKovalenko/fff.nvim",
        build = function()
            require("fff.download").download_or_build_binary()
        end,
        cond = vim.g.vscode == nil,
        lazy = false,
        keys = {
            {
                "<C-p>",
                function() require('fff').find_files() end,
                desc = 'Find files (fff)',
            },
            {
                "<leader>pf",
                function() require('fff').find_files() end,
                desc = 'Find files (fff)',
            },
        },
        opts = {
            keymaps = {
                close = { '<Esc>', '<C-c>' },
            },
        },
    },
}
