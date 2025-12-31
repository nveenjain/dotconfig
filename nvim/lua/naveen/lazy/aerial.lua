return {
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
        keys = {
            { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Toggle Aerial (code outline)" },
            { "[a", "<cmd>AerialPrev<cr>", desc = "Previous aerial symbol" },
            { "]a", "<cmd>AerialNext<cr>", desc = "Next aerial symbol" },
        },
        opts = {
            layout = {
                default_direction = "right",
                min_width = 50,
                width = 50,
            },
            attach_mode = "global",
            close_on_select = false,
            show_guides = true,
        },
    },
}
