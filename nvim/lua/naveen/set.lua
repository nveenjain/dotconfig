vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50  -- Controls how long to wait before triggering CursorHold events (affects NES in insert mode)

vim.opt.colorcolumn = "88"

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hidden = true

-- UI improvements
vim.opt.fillchars = {
    vert = " ",     -- vertical separator
    horiz = " ",    -- horizontal separator
    horizup = " ",
    horizdown = " ",
    vertleft = " ",
    vertright = " ",
    verthoriz = " ",
}

-- Increase syntax highlighting limits for large files
vim.opt.synmaxcol = 300     -- Syntax highlight up to 300 columns (default is 3000)
vim.opt.redrawtime = 2000   -- Prevent freezes on complex files (was 10000)
vim.g.syntax_on = true      -- Ensure syntax is enabled

-- Performance optimizations
-- NOTE: lazyredraw removed - deprecated in Neovim 0.11, prevents
-- treesitter/LSP highlights from rendering until manual :e
vim.opt.shortmess:append({
    W = true,  -- Don't print "written" when writing
    I = true,  -- Don't show intro message
    c = true,  -- Don't show completion messages
    C = true,  -- Don't show scanning messages
})

-- Window/split behavior
vim.opt.splitright = true   -- Vertical splits open right
vim.opt.splitbelow = true   -- Horizontal splits open below

-- UX improvements
vim.opt.cursorline = true   -- Highlight current line
vim.opt.sidescrolloff = 8   -- Horizontal scroll padding (matches scrolloff)
vim.opt.timeoutlen = 300    -- Time for mapped sequence (ms)
vim.opt.ttimeoutlen = 10    -- Time for terminal key code (ms)
vim.opt.mouse = 'a'         -- Enable mouse in all modes
vim.opt.showmatch = true    -- Briefly jump to matching bracket
vim.opt.matchtime = 2       -- 0.2s highlight duration
vim.opt.confirm = true      -- Prompt before destructive actions
