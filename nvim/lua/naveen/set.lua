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

vim.opt.updatetime = 50

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
vim.opt.redrawtime = 10000  -- Allow more time for syntax highlighting (default is 2000ms)
vim.g.syntax_on = true      -- Ensure syntax is enabled
