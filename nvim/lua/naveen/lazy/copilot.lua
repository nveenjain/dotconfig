return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        accept = "<C-l>",
                        accept_word = false,
                        accept_line = false,
                        next = "<C-]>",
                        prev = "<C-[>",
                        dismiss = "<C-;>",
                    },
                },
                panel = {
                    enabled = false,
                },
                filetypes = {
                    yaml = false,
                    markdown = false,
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ["."] = false,
                },
                copilot_node_command = 'node',
            })
        end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
        },
        build = "make tiktoken", -- Optional for better token counting
        cmd = "CopilotChat",
        opts = {
            debug = false,
            model = "gpt-4o",
            temperature = 0.1,
            window = {
                layout = 'vertical',
                width = 0.5,
                height = 0.5,
                relative = 'editor',
                border = 'rounded',
            },
            auto_insert_mode = true,
            show_help = true,
        },
        keys = {
            {
                "<leader>cc",
                "<cmd>CopilotChatToggle<cr>",
                desc = "Toggle Copilot Chat",
            },
            {
                "<leader>ce",
                "<cmd>CopilotChatExplain<cr>",
                mode = { "n", "v" },
                desc = "Explain code",
            },
            {
                "<leader>ct",
                "<cmd>CopilotChatTests<cr>",
                mode = { "n", "v" },
                desc = "Generate tests",
            },
            {
                "<leader>cf",
                "<cmd>CopilotChatFix<cr>",
                mode = { "n", "v" },
                desc = "Fix code",
            },
            {
                "<leader>co",
                "<cmd>CopilotChatOptimize<cr>",
                mode = { "n", "v" },
                desc = "Optimize code",
            },
            {
                "<leader>cd",
                "<cmd>CopilotChatDocs<cr>",
                mode = { "n", "v" },
                desc = "Generate docs",
            },
            {
                "<leader>cr",
                "<cmd>CopilotChatReset<cr>",
                desc = "Reset chat",
            },
        },
    },
}