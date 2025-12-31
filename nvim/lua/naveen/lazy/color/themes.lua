---@file color/themes.lua
---@description Color scheme plugin specifications
---@requires naveen.core.vscode

local core = require("naveen.core")

-- All color scheme plugins
-- Each theme is lazy-loaded and only activated when selected via Themery
return {
    -- Tokyo Night
    {
        "folke/tokyonight.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = true,
                terminal_colors = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })
        end,
    },

    -- Kanagawa
    {
        "rebelot/kanagawa.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("kanagawa").setup({
                compile = true,
                undercurl = true,
                commentStyle = { italic = true },
                keywordStyle = { italic = true },
                statementStyle = { bold = true },
                transparent = true,
                terminalColors = true,
                colors = {
                    theme = {
                        dragon = { ui = { bg_gutter = "none" } },
                        all = { ui = { bg = "none", bg_dim = "none", bg_gutter = "none" } },
                    },
                },
                theme = "dragon",
                background = { dark = "dragon", light = "lotus" },
            })
        end,
    },

    -- Catppuccin
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = true,
                term_colors = true,
                styles = {
                    comments = { "italic" },
                    keywords = { "italic" },
                },
            })
        end,
    },

    -- Rose Pine
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("rose-pine").setup({
                variant = "moon",
                dark_variant = "moon",
                disable_background = true,
                disable_float_background = true,
                styles = { italic = true, transparency = true },
            })
        end,
    },

    -- Gruvbox Material
    {
        "sainnhe/gruvbox-material",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_foreground = "material"
            vim.g.gruvbox_material_transparent_background = 2
            vim.g.gruvbox_material_enable_italic = 1
            vim.g.gruvbox_material_better_performance = 1
        end,
    },

    -- Nightfox (Carbonfox)
    {
        "EdenEast/nightfox.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("nightfox").setup({
                options = {
                    transparent = true,
                    terminal_colors = true,
                    styles = { comments = "italic", keywords = "italic" },
                },
            })
        end,
    },

    -- Dracula
    {
        "Mofiqul/dracula.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("dracula").setup({
                transparent_bg = true,
                italic_comment = true,
            })
        end,
    },

    -- Nord
    {
        "shaunsingh/nord.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            vim.g.nord_contrast = true
            vim.g.nord_borders = false
            vim.g.nord_disable_background = true
            vim.g.nord_italic = true
        end,
    },

    -- OneDark
    {
        "navarasu/onedark.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("onedark").setup({
                style = "dark",
                transparent = true,
                term_colors = true,
                code_style = {
                    comments = "italic",
                    keywords = "italic",
                },
            })
        end,
    },

    -- Everforest
    {
        "sainnhe/everforest",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            vim.g.everforest_background = "hard"
            vim.g.everforest_transparent_background = 2
            vim.g.everforest_enable_italic = 1
            vim.g.everforest_better_performance = 1
        end,
    },

    -- Oxocarbon
    {
        "nyoom-engineering/oxocarbon.nvim",
        lazy = true,
        cond = core.not_vscode,
    },

    -- Nightfly
    {
        "bluz71/vim-nightfly-colors",
        name = "nightfly",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            vim.g.nightflyTransparent = true
            vim.g.nightflyItalics = true
        end,
    },

    -- Sonokai
    {
        "sainnhe/sonokai",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            vim.g.sonokai_style = "default"
            vim.g.sonokai_transparent_background = 2
            vim.g.sonokai_enable_italic = 1
            vim.g.sonokai_better_performance = 1
        end,
    },

    -- Ayu
    {
        "Shatur/neovim-ayu",
        name = "ayu",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("ayu").setup({
                mirage = true,
                terminal = true,
                overrides = {
                    Normal = { bg = "None" },
                    NormalFloat = { bg = "None" },
                    SignColumn = { bg = "None" },
                },
            })
        end,
    },

    -- Material
    {
        "marko-cerovac/material.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("material").setup({
                contrast = { terminal = true, floating_windows = true },
                styles = { comments = { italic = true }, keywords = { italic = true } },
                disable = { background = true },
            })
            vim.g.material_style = "deep ocean"
        end,
    },

    -- Poimandres
    {
        "olivercederborg/poimandres.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("poimandres").setup({
                disable_background = true,
                disable_float_background = true,
            })
        end,
    },

    -- Cyberdream
    {
        "scottmckendry/cyberdream.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("cyberdream").setup({
                transparent = true,
                italic_comments = true,
                borderless_telescope = false,
            })
        end,
    },

    -- Solarized Osaka
    {
        "craftzdog/solarized-osaka.nvim",
        lazy = true,
        cond = core.not_vscode,
        config = function()
            require("solarized-osaka").setup({
                transparent = true,
                terminal_colors = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })
        end,
    },
}
