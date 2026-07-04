return {
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        keys = {
            { "<leader>gvd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },
            { "<leader>gvh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: File history" },
            { "<leader>gvH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: Branch history" },
            { "<leader>gvq", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
            { "<leader>gvm", "<cmd>DiffviewOpen master<cr>", desc = "Diffview: Diff against master" },
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
