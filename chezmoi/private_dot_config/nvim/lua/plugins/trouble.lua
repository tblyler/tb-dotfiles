return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("trouble").setup()

		local keys = require("helpers.keys")
		keys.map("", "<leader>xx", "<cmd>TroubleToggle<cr>")
		keys.map("", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
		keys.map("", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>")
		keys.map("", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>")
		keys.map("", "<leader>xl", "<cmd>TroubleToggle loclist<cr>")
	end
}
