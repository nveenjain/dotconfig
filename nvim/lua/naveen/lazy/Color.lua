-- Transparency and custom highlights function
function BgColor()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
	vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
	vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
	vim.api.nvim_set_hl(0, "Folded", { bg = "none" })
	vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
	vim.api.nvim_set_hl(0, "SpecialKey", { bg = "none" })
	vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
	vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
	vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#3a3a3a" })

	-- High contrast symbols
	vim.api.nvim_set_hl(0, "Operator", { fg = "#87ff00", bold = true })
	vim.api.nvim_set_hl(0, "Delimiter", { fg = "#ff9e3b", bold = true })
	vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#7fb4ca", bold = true })
	vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = "#ffa066", bold = true })
	vim.api.nvim_set_hl(0, "@punctuation.special", { fg = "#ff5d62", bold = true })
	vim.api.nvim_set_hl(0, "@operator", { fg = "#87ff00", bold = true })

	-- Notification backgrounds
	local light_bg = "#2a2a3e"
	vim.api.nvim_set_hl(0, "NotifyBackground", { bg = light_bg })
	vim.api.nvim_set_hl(0, "NotifyERRORBorder", { bg = light_bg, fg = "#db4b4b" })
	vim.api.nvim_set_hl(0, "NotifyWARNBorder", { bg = light_bg, fg = "#e0af68" })
	vim.api.nvim_set_hl(0, "NotifyINFOBorder", { bg = light_bg, fg = "#0db9d7" })
	vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { bg = light_bg, fg = "#8B8B8B" })
	vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { bg = light_bg, fg = "#bb9af7" })
	vim.api.nvim_set_hl(0, "NotifyERRORIcon", { bg = light_bg, fg = "#db4b4b" })
	vim.api.nvim_set_hl(0, "NotifyWARNIcon", { bg = light_bg, fg = "#e0af68" })
	vim.api.nvim_set_hl(0, "NotifyINFOIcon", { bg = light_bg, fg = "#0db9d7" })
	vim.api.nvim_set_hl(0, "NotifyDEBUGIcon", { bg = light_bg, fg = "#8B8B8B" })
	vim.api.nvim_set_hl(0, "NotifyTRACEIcon", { bg = light_bg, fg = "#bb9af7" })
	vim.api.nvim_set_hl(0, "NotifyERRORTitle", { bg = light_bg, fg = "#db4b4b" })
	vim.api.nvim_set_hl(0, "NotifyWARNTitle", { bg = light_bg, fg = "#e0af68" })
	vim.api.nvim_set_hl(0, "NotifyINFOTitle", { bg = light_bg, fg = "#0db9d7" })
	vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { bg = light_bg, fg = "#8B8B8B" })
	vim.api.nvim_set_hl(0, "NotifyTRACETitle", { bg = light_bg, fg = "#bb9af7" })
	vim.api.nvim_set_hl(0, "NotifyERRORBody", { bg = light_bg, fg = "#c0caf5" })
	vim.api.nvim_set_hl(0, "NotifyWARNBody", { bg = light_bg, fg = "#c0caf5" })
	vim.api.nvim_set_hl(0, "NotifyINFOBody", { bg = light_bg, fg = "#c0caf5" })
	vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { bg = light_bg, fg = "#c0caf5" })
	vim.api.nvim_set_hl(0, "NotifyTRACEBody", { bg = light_bg, fg = "#c0caf5" })

	-- Snacks.nvim notifications
	vim.api.nvim_set_hl(0, "SnacksNotifierInfo", { bg = light_bg, fg = "#0db9d7" })
	vim.api.nvim_set_hl(0, "SnacksNotifierWarn", { bg = light_bg, fg = "#e0af68" })
	vim.api.nvim_set_hl(0, "SnacksNotifierError", { bg = light_bg, fg = "#db4b4b" })
	vim.api.nvim_set_hl(0, "SnacksNotifierDebug", { bg = light_bg, fg = "#8B8B8B" })
	vim.api.nvim_set_hl(0, "SnacksNotifierTrace", { bg = light_bg, fg = "#bb9af7" })
	vim.api.nvim_set_hl(0, "SnacksNotifier", { bg = light_bg, fg = "#c0caf5" })
	vim.api.nvim_set_hl(0, "SnacksNotifierTitle", { bg = light_bg, fg = "#7aa2f7" })
	vim.api.nvim_set_hl(0, "SnacksNotifierBorder", { bg = light_bg, fg = "#565f89" })
	vim.api.nvim_set_hl(0, "SnacksNotifierIcon", { bg = light_bg, fg = "#7aa2f7" })
end

-- Keybind for theme picker
vim.keymap.set("n", "<leader>th", ":Themery<CR>", { desc = "Theme picker" })

return {
	-- Themery - Theme Manager
	{
		"zaldih/themery.nvim",
		lazy = false,
		priority = 1000,
		cond = vim.g.vscode == nil,
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
				globalAfter = [[BgColor()]],
			})
			BgColor()
		end,
	},

	-- Tokyo Night
	{
		"folke/tokyonight.nvim",
		lazy = true,
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
	},

	-- Nightfly
	{
		"bluz71/vim-nightfly-colors",
		name = "nightfly",
		lazy = true,
		cond = vim.g.vscode == nil,
		config = function()
			vim.g.nightflyTransparent = true
			vim.g.nightflyItalics = true
		end,
	},

	-- Sonokai
	{
		"sainnhe/sonokai",
		lazy = true,
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
		cond = vim.g.vscode == nil,
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
