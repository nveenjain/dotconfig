---@file neo-tree.lua
---@description File explorer with git integration
---@requires naveen.core

local core = require("naveen.core")
local constants = require("naveen.core.constants")
local highlights = require("naveen.core.highlights")

return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        cond = core.not_vscode,
        keys = {
            {
                "<leader>e",
                function()
                    local git_root = core.get_git_root()
                    if git_root then
                        vim.cmd("Neotree toggle dir=" .. vim.fn.fnameescape(git_root))
                    else
                        vim.cmd("Neotree toggle")
                    end
                end,
                desc = "Explorer: Toggle Neo-tree",
            },
            {
                "<leader>pv",
                function()
                    -- Check if neo-tree is open and close it, otherwise reveal
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].filetype == "neo-tree" then
                            vim.cmd("Neotree close")
                            return
                        end
                    end
                    -- Not open, reveal current file
                    local git_root = core.get_git_root()
                    if git_root then
                        vim.cmd("Neotree reveal dir=" .. vim.fn.fnameescape(git_root))
                    else
                        vim.cmd("Neotree reveal")
                    end
                end,
                desc = "Explorer: Toggle/Reveal in Neo-tree",
            },
        },
        opts = {
            close_if_last_window = true,
            enable_git_status = true,
            enable_diagnostics = true,
            source_selector = {
                winbar = false,
                statusline = false,
            },
            filesystem = {
                bind_to_cwd = false,
                cwd_target = {
                    sidebar = "none",
                    current = "none",
                },
                follow_current_file = {
                    enabled = true,
                    leave_dirs_open = true,
                },
                use_libuv_file_watcher = true,
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
                find_by_full_path_words = true,
            },
            window = {
                position = "left",
                width = constants.NEO_TREE_WIDTH,
                mappings = {
                    ["<C-c>"] = "close_window",
                    ["<Esc>"] = "close_window",
                    ["q"] = "close_window",
                    ["<cr>"] = "open",
                    ["<C-v>"] = "open_vsplit",
                    ["<C-s>"] = "open_split",
                    ["<C-t>"] = "open_tabnew",
                    ["P"] = { "toggle_preview", config = { use_float = true } },
                    ["a"] = "add",
                    ["d"] = "delete",
                    ["r"] = "rename",
                    ["y"] = "copy_to_clipboard",
                    ["x"] = "cut_to_clipboard",
                    ["p"] = "paste_from_clipboard",
                    ["H"] = "toggle_hidden",
                    ["R"] = "refresh",
                    ["?"] = "show_help",
                },
            },
            default_component_configs = {
                diagnostics = {
                    symbols = {
                        hint = "󰌵",
                        info = "",
                        warn = "",
                        error = "",
                    },
                    highlights = {
                        hint = "DiagnosticSignHint",
                        info = "DiagnosticSignInfo",
                        warn = "DiagnosticSignWarn",
                        error = "DiagnosticSignError",
                    },
                },
                git_status = {
                    symbols = {
                        added = "+",
                        modified = "~",
                        deleted = "x",
                        renamed = "r",
                        untracked = "?",
                        ignored = "◌",
                        unstaged = "○",
                        staged = "●",
                        conflict = "!",
                    },
                },
            },
        },
        config = function(_, opts)
            -- Apply git status colors from centralized highlights
            highlights.setup_neotree()

            require("neo-tree").setup(opts)

            -- Close neo-tree before session save to prevent broken restore
            vim.api.nvim_create_autocmd("User", {
                pattern = "PersistenceSavePre",
                callback = function()
                    vim.cmd("Neotree close")
                end,
            })

            -- Ensure neo-tree is closed on startup (in case session restored it)
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    vim.defer_fn(function()
                        vim.cmd("Neotree close")
                    end, constants.NEO_TREE_CLOSE_DELAY)
                end,
            })

            -- When navigating from fugitive, ensure neo-tree stays at git root
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function(args)
                    local prev_buf = vim.fn.bufnr("#")
                    if prev_buf == -1 then
                        return
                    end

                    local prev_ft = vim.bo[prev_buf].filetype
                    if prev_ft ~= "fugitive" then
                        return
                    end

                    -- Check if neo-tree is open
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].filetype == "neo-tree" then
                            vim.defer_fn(function()
                                local git_root = core.get_git_root()
                                if git_root then
                                    local path = vim.api.nvim_buf_get_name(args.buf)
                                    if path ~= "" then
                                        vim.cmd("Neotree dir=" .. vim.fn.fnameescape(git_root) .. " reveal_file=" .. vim.fn.fnameescape(path))
                                    else
                                        vim.cmd("Neotree dir=" .. vim.fn.fnameescape(git_root))
                                    end
                                end
                            end, 50)
                            return
                        end
                    end
                end,
            })
        end,
    },
}
