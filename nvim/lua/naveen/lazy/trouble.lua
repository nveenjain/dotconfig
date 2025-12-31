return {
    {
        "folke/trouble.nvim",
        cmd = { "Trouble", "TroubleToggle" },
        keys = {
            { "<leader>tt", function() require("trouble").toggle("diagnostics") end, desc = "Toggle Trouble" },
            { "<leader>tq", function() require("trouble").toggle("quickfix") end, desc = "Quickfix List" },
            { "[t", function() require("trouble").next({skip_groups = true, jump = true}) end, desc = "Next Trouble" },
            { "]t", function() require("trouble").previous({skip_groups = true, jump = true}) end, desc = "Prev Trouble" },
        },
        opts = {
            use_diagnostic_signs = true,
            auto_refresh = true,
            auto_close = false,
            auto_open = false,
            auto_preview = true,
            auto_jump = false,
        },
    },
}
