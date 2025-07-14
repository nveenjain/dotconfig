return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        event = "VeryLazy",
        enabled = true,
        branch = "canary", -- while in development
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
        },
        opts = {
            debug = false, -- Enable debugging
        },
        config = function(_, opts)
            require("CopilotChat").setup(opts)
        end,
        keys = {
            { "<leader>aC", ":CopilotChat<CR>", desc = "Copilot Chat" },
        },
    },
}
