return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    cond = vim.g.vscode == nil,
    config = function()
        require('nvim-treesitter.configs').setup ({
            -- A list of parser names, or "all" (the five listed parsers should always be installed)
            ensure_installed = { "javascript", "typescript", "go", "rust", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,
            indent = {
                enable = true
            },

            -- List of parsers to ignore installing (or "all")
            ignore_install = { "javascript" },


            highlight = {
                enable = true,
                disable = function(lang, buf)
                    -- Respect large_file flag from init.lua
                    if vim.b[buf].large_file then
                        return true
                    end

                    -- 2MB threshold (matches large_file_threshold in init.lua)
                    local max_filesize = 2 * 1024 * 1024
                    if lang == "go" then
                        max_filesize = 10 * 1024 * 1024 -- 10 MB for Go files
                    end

                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end

                    -- Workaround for Go parser bug when deleting at end of file
                    if lang == "go" then
                        local line_count = vim.api.nvim_buf_line_count(buf)
                        if line_count < 5 then
                            return true
                        end
                    end
                    return false
                end,

                -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
                -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
                -- the name of the parser)
                -- list of language that will be disabled
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
            },
        })
        -- Custom parser configuration
        vim.treesitter.language.register('templ', 'templ')
    end

}
