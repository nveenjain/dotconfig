---@file treesitter.lua
---@description nvim-treesitter on the `main` branch (required for Neovim 0.12+).
---  The `master` branch is EOL and crashes on 0.12 because directive handlers
---  now always receive capture lists. On `main` we install parsers explicitly
---  and start highlighting ourselves via a FileType autocmd.

return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    priority = 900,
    cond = vim.g.vscode == nil,
    config = function()
        local ts = require('nvim-treesitter')

        -- Parsers to keep installed (async; installs to stdpath('data')/site).
        ts.install({
            'javascript', 'typescript', 'go', 'rust', 'lua',
            'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline', 'yaml',
        })

        -- Custom parser registration.
        vim.treesitter.language.register('templ', 'templ')

        -- `main` doesn't wire up highlighting/indent for us; do it per-buffer.
        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('naveen_treesitter', { clear = true }),
            callback = function(ev)
                local buf = ev.buf

                -- Respect large_file flag from init.lua (handles fs_stat already).
                if vim.b[buf].large_file then
                    return
                end

                local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

                -- Workaround for Go parser bug when deleting at end of file.
                if lang == 'go' and vim.api.nvim_buf_line_count(buf) < 5 then
                    return
                end

                -- Only enable when a parser is actually installed.
                if not pcall(vim.treesitter.start, buf, lang) then
                    return
                end

                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
