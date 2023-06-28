return {
	{
		"echasnovski/mini.nvim",
		config = function()
			local animate = require("mini.animate")
			animate.setup({
				cursor = {
					timing = animate.gen_timing.linear({ duration = 100, unit = "total" })
				},
				scroll = {
					timing = animate.gen_timing.linear({ duration = 100, unit = "total" })
				},
				resize = {
					timing = animate.gen_timing.linear({ duration = 100, unit = "total" })
				},
				open = {
					timing = animate.gen_timing.linear({ duration = 100, unit = "total" })
				},
				close = {
					timing = animate.gen_timing.linear({ duration = 100, unit = "total" })
				},
			})
			require("mini.bufremove").setup()
			require("mini.comment").setup()
			require("mini.completion").setup()
			require("mini.cursorword").setup()
			require("mini.indentscope").setup({
				options = {
					border = "both",
					indent_at_cursor = true,
					try_as_border = true,
				},
				symbol = "│"
			})
			require("mini.surround").setup()
			require("mini.trailspace").setup()

			vim.opt.list = true
			vim.opt.listchars = "tab:│ "
			vim.api.nvim_command(":command Bd lua MiniBufremove.delete()")
			vim.api.nvim_command(":command FixWhitespace lua MiniTrailspace.trim()")
		end,
	}
}
