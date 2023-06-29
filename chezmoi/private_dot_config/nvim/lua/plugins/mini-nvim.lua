return {
	{
		"echasnovski/mini.nvim",
		config = function()
			local animate = require("mini.animate")
			local timing = animate.gen_timing.linear({ duration = duration, unit = "total" })
			animate.setup({
				cursor = {
					timing = timing
				},
				scroll = {
					timing = timing
				},
				resize = {
					timing = timing
				},
				open = {
					timing = timing
				},
				close = {
					timing = timing
				},
			})
			require("mini.bufremove").setup()
			require("mini.comment").setup()
			require("mini.completion").setup()
			require("mini.cursorword").setup()
			require("mini.pairs").setup()
			require("mini.tabline").setup()
			require("mini.starter").setup()
			require("mini.statusline").setup()
			require("mini.surround").setup()
			require("mini.trailspace").setup()

			vim.api.nvim_command(":command Bd lua MiniBufremove.delete()")
			vim.api.nvim_command(":command FixWhitespace lua MiniTrailspace.trim()")
		end,
	}
}
