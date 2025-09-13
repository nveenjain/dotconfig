function BgColor()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	-- Fix sign column and separators
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
	vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
	vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
	vim.api.nvim_set_hl(0, "Folded", { bg = "none" })
	vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
	vim.api.nvim_set_hl(0, "SpecialKey", { bg = "none" })
	vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
	vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
	-- Fix status line
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
	-- Make colorcolumn appear as a thin line
	vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#3a3a3a" })
	
	-- High contrast symbols for better visibility
	vim.api.nvim_set_hl(0, "Operator", { fg = "#87ff00", bold = true })     -- Bright green operators
	vim.api.nvim_set_hl(0, "Delimiter", { fg = "#ff9e3b", bold = true })    -- Bright orange delimiters
	vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#7fb4ca", bold = true }) -- Bright blue brackets
	vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = "#ffa066", bold = true }) -- Orange punctuation
	vim.api.nvim_set_hl(0, "@punctuation.special", { fg = "#ff5d62", bold = true }) -- Red special punctuation
	vim.api.nvim_set_hl(0, "@operator", { fg = "#87ff00", bold = true })    -- Bright green operators for treesitter
	
	-- Fix notification backgrounds - light background
	local light_bg = "#2a2a3e"  -- Slightly light background
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
	
	-- Snacks.nvim notification highlights
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
return {
    {
      'rebelot/kanagawa.nvim',
      lazy = false, -- make sure we load this during startup if it is your main colorscheme
      priority = 1000, -- make sure to load this before all the other start plugins
    -- disable for vscode
    cond = vim.g.vscode == nil,
      config = function()
          require("kanagawa").setup({
              compile = false,
              undercurl = true,
              commentStyle = { italic = true },
              functionStyle = {},
              keywordStyle = { italic = true},
              statementStyle = { bold = true },
              typeStyle = {},
              transparent = true,
              dimInactive = false,
              terminalColors = true,
              colors = {
                  palette = {},
                  theme = { 
                      wave = {}, 
                      lotus = {}, 
                      dragon = {
                          ui = {
                              bg_gutter = "none"
                          }
                      },
                      all = {
                          ui = {
                              bg = "none",
                              bg_dim = "none",
                              bg_gutter = "none"
                          }
                      }
                  },
              },
              theme = "dragon", -- Load "dragon" theme (dark hacker vibes)
              background = {
                  dark = "dragon",
                  light = "lotus"
              },
          })
          vim.cmd.colorscheme("kanagawa-dragon")
        BgColor()
      end
    },
}
