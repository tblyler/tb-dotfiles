return {
	{
		"phaazon/hop.nvim",
		config = function()
			local hop = require("hop")
			hop.setup()

			local directions = require("hop.hint").HintDirection
			local map = require("helpers.keys").map

			map("", "<leader><leader>j", function()
					hop.hint_lines({direction = directions.AFTER_CURSOR})
				end)
			map("", "<leader><leader>k", function()
					hop.hint_lines({direction = directions.BEFORE_CURSOR})
				end)
			map("", "<leader><leader>l", function()
					hop.hint_words({direction = directions.AFTER_CURSOR, current_line_only = true})
				end)
			map("", "<leader><leader>h", function()
					hop.hint_words({direction = directions.BEFORE_CURSOR, current_line_only = true})
				end)
		end,
	}
}
