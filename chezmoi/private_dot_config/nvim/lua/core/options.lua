local opts = {
	termguicolors = true, -- enable 24 bit colors
	-- tabs look like 4 spaces {
	expandtab = true,
	tabstop = 4,
	shiftwidth = 4,
	softtabstop = 4,
	-- }
	number = true, -- show line numbers
	mouse = 'c', -- disable mouse
	laststatus = 2, -- always show the status line
	autoindent = true, -- turn on autoindent
	smarttab = true, -- turn on smart tabs
	incsearch = true, -- turn on incremental search
	ruler = true, -- show ruler on page
	lazyredraw = true, -- make large file bearable
	regexpengine = 1, -- make searching large files bearable
	background = 'dark' -- use dark theme
}

for opt, val in pairs(opts) do
	vim.o[opt] = val
end
