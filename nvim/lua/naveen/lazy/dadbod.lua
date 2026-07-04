---@file dadbod.lua
---@description SQL/Postgres client + completion inside nvim (vim-dadbod-ui).
---  Query the treasury DB and get table/column completion without leaving the
---  editor. Connections persist under ~/.local/share/db_ui (added via :DBUI).

return {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
        { "tpope/vim-dadbod", lazy = true },
        { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_show_database_icon = 1
        vim.g.db_ui_win_position = "left"
        -- Save executed queries under the repo so they travel with worktrees.
        vim.g.db_ui_save_location = "~/.local/share/db_ui"
        vim.g.db_ui_tmp_query_location = "~/.local/share/db_ui/tmp"
    end,
    keys = {
        { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
        { "<leader>dB", "<cmd>DBUIAddConnection<CR>", desc = "DB add connection" },
    },
    config = function()
        -- Wire dadbod completion into nvim-cmp for SQL buffers only.
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "sql", "mysql", "plsql" },
            callback = function()
                local ok, cmp = pcall(require, "cmp")
                if not ok then return end
                cmp.setup.buffer({
                    sources = cmp.config.sources({
                        { name = "vim-dadbod-completion" },
                        { name = "luasnip" },
                        { name = "buffer" },
                    }),
                })
            end,
        })
    end,
}
