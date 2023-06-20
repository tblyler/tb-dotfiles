return {
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.animate").setup()
			require("mini.bufremove").setup()
			require("mini.comment").setup()
			require("mini.completion").setup()
			require("mini.cursorword").setup()
			require("mini.indentscope").setup({
				symbol = "│"
			})
			require("mini.surround").setup()
			require("mini.trailspace").setup()

			vim.api.nvim_command(":command Bd lua MiniBufremove.delete()")
			vim.api.nvim_command(":command FixWhitespace lua MiniTrailspace.trim()")
		end,
	}
}
