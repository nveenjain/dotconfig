---@file remap.lua
---@description All keybindings for Neovim
---@author Naveen

--------------------------------------------------------------------------------
-- Leader Key
--------------------------------------------------------------------------------

vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "

--------------------------------------------------------------------------------
-- Navigation & Movement
--------------------------------------------------------------------------------

-- Line movement in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move: Line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move: Line up" })

-- Join lines keeping cursor position
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines" })

-- Scrolling with centered cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })

-- Search with centered cursor
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result" })

--------------------------------------------------------------------------------
-- Clipboard & Registers
--------------------------------------------------------------------------------

-- Paste without overwriting register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste: Preserve register" })

-- Yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank: To clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank: Line to clipboard" })

-- Delete to void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete: To void" })

--------------------------------------------------------------------------------
-- Editing
--------------------------------------------------------------------------------

-- Make C-c trigger InsertLeave like Esc does
vim.keymap.set("i", "<C-c>", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Exit insert mode" })

-- Disable Q (ex mode)
vim.keymap.set("n", "Q", "<nop>")

-- Format current buffer
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "LSP: Format buffer" })

-- Search and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search: Replace word" })

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "File: Make executable" })

-- Source current file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end, { desc = "Source current file" })

--------------------------------------------------------------------------------
-- Quickfix & Location List
--------------------------------------------------------------------------------

vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Quickfix: Next" })
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Quickfix: Previous" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Location: Next" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Location: Previous" })

--------------------------------------------------------------------------------
-- External Tools
--------------------------------------------------------------------------------

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux new tmux-sessionizer<CR>", { desc = "Tmux: Sessionizer" })

--------------------------------------------------------------------------------
-- File Explorer
--------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>pv", vim.cmd.Vex, { desc = "Explorer: Vertical split" })

--------------------------------------------------------------------------------
-- Git (Gitsigns)
--------------------------------------------------------------------------------

vim.keymap.set("n", "]g", ":Gitsigns next_hunk<CR>", { silent = true, desc = "Git: Next hunk" })
vim.keymap.set("n", "[g", ":Gitsigns prev_hunk<CR>", { silent = true, desc = "Git: Previous hunk" })
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { silent = true, desc = "Git: Preview hunk" })
vim.keymap.set("n", "<leader>gh", ":Gitsigns stage_hunk<CR>", { silent = true, desc = "Git: Stage hunk" })
vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { silent = true, desc = "Git: Reset hunk" })
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { silent = true, desc = "Git: Blame line" })
vim.keymap.set("n", "<leader>gd", ":Gitsigns diffthis<CR>", { silent = true, desc = "Git: Diff this" })

--------------------------------------------------------------------------------
-- Git (Fugitive)
--------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>gc", ":Git checkout ", { desc = "Git: Checkout branch" })
vim.keymap.set("n", "<leader>gB", ":Git branch<CR>", { desc = "Git: List branches" })
vim.keymap.set("n", "<leader>gm", ":Git checkout main<CR>", { desc = "Git: Checkout main" })
vim.keymap.set("n", "<leader>gM", ":Git checkout master<CR>", { desc = "Git: Checkout master" })

--------------------------------------------------------------------------------
-- Window Management
--------------------------------------------------------------------------------

vim.keymap.set("n", "<C-w>v", function()
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
end, { desc = "Window: Split vertical" })

vim.keymap.set("n", "<C-w>s", function()
    vim.cmd("split")
    vim.cmd("wincmd j")
end, { desc = "Window: Split horizontal" })

-- Window maximize toggle
vim.keymap.set("n", "<leader>m", function()
    local win = vim.api.nvim_get_current_win()
    local is_maximized = vim.t.maximized_window == win

    if is_maximized then
        vim.cmd("wincmd =")
        vim.t.maximized_window = nil
    else
        vim.cmd("wincmd |")
        vim.cmd("wincmd _")
        vim.t.maximized_window = win
    end
end, { desc = "Window: Toggle maximize" })

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic: Open float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostic: Previous" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostic: Next" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic: To loclist" })

--------------------------------------------------------------------------------
-- LSP Keymaps (attached on LspAttach event)
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("NavLspKeymaps", { clear = true }),
    callback = function(e)
        local opts = { buffer = e.buf }

        -- Go to definition with smart handling for multiple results
        vim.keymap.set("n", "gd", function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            local client = clients[1]
            if not client then
                vim.notify("No LSP client attached", vim.log.levels.ERROR)
                return
            end

            local params = vim.lsp.util.make_position_params(nil, client.offset_encoding)
            vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, _, _)
                if err then
                    vim.notify("Error when finding definition: " .. err.message, vim.log.levels.ERROR)
                    return
                end

                if not result or vim.tbl_isempty(result) then
                    vim.notify("No definition found", vim.log.levels.INFO)
                    return
                end

                -- Convert result to list if it's a single item
                if not vim.islist(result) then
                    result = { result }
                end

                -- If only one result, jump directly
                if #result == 1 then
                    vim.lsp.util.show_document(result[1], client.offset_encoding, { reuse_win = true, focus = true })
                else
                    -- Multiple results, use quickfix
                    vim.fn.setqflist({}, " ", {
                        title = "LSP definitions",
                        items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
                    })
                    vim.cmd("copen")
                end
            end)
        end, vim.tbl_extend("force", opts, { desc = "LSP: Go to definition" }))

        -- Hover documentation
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP: Hover" }))

        -- Workspace symbols
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "LSP: Workspace symbols" }))

        -- Diagnostics
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "LSP: Show diagnostic" }))

        -- Code actions
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP: Code action" }))
        vim.keymap.set("v", "<leader>vca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP: Code action" }))

        -- References
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "LSP: References" }))

        -- Implementation
        vim.keymap.set("n", "<leader>vi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "LSP: Implementation" }))

        -- Rename
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP: Rename" }))

        -- Signature help
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "LSP: Signature help" }))
    end,
})
