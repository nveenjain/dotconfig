return {
    "f-person/git-blame.nvim",
    opts = {
        enabled = false,
        date_format = "%Y-%m-%d",
        message_template = "  <author> • <date> • <summary>",
        virtual_text_column = 88,
        highlight_group = "Comment",
    },
    keys = {
        { "<leader>gB", "<cmd>GitBlameToggle<CR>", desc = "Toggle Git Blame" },
    },
}
