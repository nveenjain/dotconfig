return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    -- disable for vscode
    cond = vim.g.vscode == nil,
    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                'ts_ls', 'golangci_lint_ls', 'gopls', 'lua_ls', 'rust_analyzer', 'jsonls', 'pyright'
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
                ["gopls"] = function()
                    local lspconfig = require('lspconfig')

                    -- Detect local module from go.mod for import grouping
                    local function get_local_module()
                        local gomod = vim.fn.findfile("go.mod", ".;")
                        if gomod ~= "" then
                            local lines = vim.fn.readfile(gomod, "", 1)
                            if lines[1] then
                                return lines[1]:match("^module%s+(%S+)") or ""
                            end
                        end
                        return ""
                    end

                    lspconfig.gopls.setup {
                        capabilities = capabilities,
                        settings = {
                            gopls = {
                                staticcheck = true,
                                gofumpt = true,
                                usePlaceholders = true,
                                completeUnimported = true,
                                analyses = {
                                    unusedparams = true,
                                    shadow = true,
                                },
                                ["local"] = get_local_module(),
                            },
                        },
                    }
                end,
                ["buf_ls"] = function()
                    -- Disabled in favor of protols which supports protoc-style include paths
                end,
                ["pyright"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.pyright.setup {
                        capabilities = capabilities,
                        settings = {
                            python = {
                                venvPath = ".",
                                venv = ".venv",
                            },
                        },
                    }
                end,
            }
        })

        -- Setup protols for Protocol Buffers (supports protoc-style include paths)
        vim.lsp.config("protols", {
            cmd = { "protols" },
            filetypes = { "proto" },
            root_markers = { "protols.toml", "buf.yaml", ".git" },
            capabilities = capabilities,
        })
        vim.lsp.enable("protols")

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-e>'] = cmp.mapping.abort(),
            }),
            sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                },
                {
                    { name = 'buffer' },
                })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = true,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
