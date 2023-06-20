return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("trouble").setup()

		local keys = require("helpers.keys")
		keys.map("", "<leader>xx", "<cmd>TroubleToggle<cr>")
	end
}
