return {
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup({
                -- Remove icons config entirely to use defaults
                -- or set use_diagnostic_signs = true to use LSP signs
                use_diagnostic_signs = true,
                auto_refresh = true,  -- Enable auto-refresh
                auto_close = false,   -- Don't auto-close when no diagnostics
                auto_open = false,    -- Don't auto-open on diagnostics
                auto_preview = true,  -- Auto-preview diagnostic under cursor
                auto_jump = false,    -- Don't auto-jump to diagnostic
            })

            vim.keymap.set("n", "<leader>tt", function()
                require("trouble").toggle("diagnostics")
            end)

            vim.keymap.set("n", "[t", function()
                require("trouble").next({skip_groups = true, jump = true});
            end)

            vim.keymap.set("n", "]t", function()
                require("trouble").previous({skip_groups = true, jump = true});
            end)

        end
    },
}
