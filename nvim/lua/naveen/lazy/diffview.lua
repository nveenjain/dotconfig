return {
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff view" },
            { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
            { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
            { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
            { "<leader>gm", "<cmd>DiffviewOpen master<cr>", desc = "Diff against master" },
        },
        opts = {
            enhanced_diff_hl = true,
            view = {
                default = { layout = "diff2_horizontal" },
                merge_tool = { layout = "diff3_horizontal" },
            },
            file_panel = {
                listing_style = "tree",
                win_config = { position = "left", width = 35 },
            },
        },
    },
}
