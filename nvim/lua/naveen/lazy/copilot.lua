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
                    debounce = 50,
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
                    ["dap-repl"] = false,
                    dapui_watches = false,
                    dapui_stacks = false,
                    dapui_breakpoints = false,
                    dapui_scopes = false,
                    dapui_console = false,
                },
                copilot_node_command = 'node',
            })
        end,
    },
}
