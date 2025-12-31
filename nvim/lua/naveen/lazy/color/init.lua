---@file color/init.lua
---@description Theme manager and highlight configuration
---@requires naveen.core.highlights, naveen.core.vscode

local core = require("naveen.core")
local highlights = require("naveen.core.highlights")

-- Backwards compatibility: Themery persists globalAfter as "BgColor()"
-- This global function ensures old persisted state still works
function BgColor()
    highlights.apply_all()
end

-- Import theme specs from themes.lua
local themes = require("naveen.lazy.color.themes")

-- Keybind for theme picker
vim.keymap.set("n", "<leader>th", ":Themery<CR>", { desc = "UI: Theme picker" })

-- Build the return table: themery manager + all theme plugins
local plugins = {
    -- Themery - Theme Manager
    {
        "zaldih/themery.nvim",
        lazy = false,
        priority = 1000,
        cond = core.not_vscode,
        config = function()
            require("themery").setup({
                themes = {
                    { name = "Tokyo Night", colorscheme = "tokyonight-night" },
                    { name = "Kanagawa Dragon", colorscheme = "kanagawa-dragon" },
                    { name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
                    { name = "Rose Pine Moon", colorscheme = "rose-pine-moon" },
                    { name = "Gruvbox Material", colorscheme = "gruvbox-material" },
                    { name = "Carbonfox", colorscheme = "carbonfox" },
                    { name = "Dracula", colorscheme = "dracula" },
                    { name = "Nord", colorscheme = "nord" },
                    { name = "OneDark", colorscheme = "onedark" },
                    { name = "Everforest", colorscheme = "everforest" },
                    { name = "Oxocarbon", colorscheme = "oxocarbon" },
                    { name = "Nightfly", colorscheme = "nightfly" },
                    { name = "Sonokai", colorscheme = "sonokai" },
                    { name = "Ayu Mirage", colorscheme = "ayu-mirage" },
                    { name = "Material Deep Ocean", colorscheme = "material" },
                    { name = "Poimandres", colorscheme = "poimandres" },
                    { name = "Cyberdream", colorscheme = "cyberdream" },
                    { name = "Solarized Osaka", colorscheme = "solarized-osaka" },
                },
                livePreview = true,
                -- Apply highlights after theme change
                globalAfter = [[require("naveen.core.highlights").apply_all()]],
            })
            -- Apply highlights on initial load
            highlights.apply_all()
        end,
    },
}

-- Append all theme plugins
for _, theme in ipairs(themes) do
    table.insert(plugins, theme)
end

return plugins
