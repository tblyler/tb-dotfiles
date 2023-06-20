-- Telescope fuzzying finding all the things
return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					}
				}
			})
			-- Enable telescope fzf native, if installed
			pcall(telescope.load_extension, "fzf")

			local telescope_builtin = require("telescope.builtin")
			local keys = require("helpers.keys")
			keys.map("", "<C-p>", telescope_builtin.find_files)
			keys.map("", "<leader>ff", telescope_builtin.find_files)
			keys.map("", "<leader>fg", telescope_builtin.live_grep)
			keys.map("", "<leader>fb", telescope_builtin.buffers)
			keys.map("", "<leader>fh", telescope_builtin.help_tags)
		end,
	}
}
