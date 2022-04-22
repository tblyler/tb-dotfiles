local g = vim.g
local opt = vim.opt
local cmd = vim.cmd

-- color theme
-- gruvbox is used via the autocmd require
g.gruvbox_contrast_dark = "hard"  -- hard contrast mode for gruvobx
opt.background = "dark"           -- make sure dark mode is used

opt.termguicolors = true          -- enable 24 bit colors
opt.mouse = 'c'                   -- disable mouse
opt.number = true                 -- show line numbers
-- opt.cursorline = true             -- highlight the line that the cursor is on
opt.laststatus = 2                -- always show the status line
opt.autoindent = true             -- turn on autoindent
opt.smarttab = true               -- turn on smart tabs
opt.incsearch = true              -- turn on incremental search
opt.ruler = true                  -- show ruler on page
opt.lazyredraw = true             -- make large files bearable
opt.regexpengine = 1              -- make searching large files bearable

-- tabs look like 4 spaces
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4

cmd('filetype plugin indent on')
