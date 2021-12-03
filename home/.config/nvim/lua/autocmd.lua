local api = vim.api

-- set the theme to gruvbox
api.nvim_command("autocmd vimenter * ++nested colorscheme gruvbox")

-- run nvim-lightbulb for all files
vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
