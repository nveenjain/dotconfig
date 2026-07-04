---@file render-markdown.lua
---@description In-buffer markdown rendering (headings, code blocks, tables,
---  callouts) for CLAUDE.md, skill docs, and research/RCA notes.

return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        heading = { sign = false },
        code = { sign = false, width = "block", min_width = 45 },
        completions = { lsp = { enabled = true } },
    },
    keys = {
        { "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render", ft = "markdown" },
    },
}
