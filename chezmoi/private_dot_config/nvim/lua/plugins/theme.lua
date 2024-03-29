
return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		opts = {
			contrast = "hard"
		},
	},
	{
		'maxmx03/dracula.nvim',
		config = function()
			local dracula = require 'dracula'
			local draculapro = require 'draculapro'

			draculapro.setup({
				theme = 'morbius'
			})

			dracula.setup {
				dracula_pro = draculapro,
				colors = draculapro.colors
			}

			vim.cmd.colorscheme 'dracula'
		end,
		dependencies = {
			{
				url = "git@git.0xdad.com:tblyler/dracula-pro.nvim.git",
			},
		},
	},
}
