local api = vim.api

local M = {}
function M.map(mode, keydef, command, opts)
    local options = {noremap = true}
    if opts then options = vim.tbl_extend("force", options, opts) end
    api.nvim_set_keymap(mode, keydef, command, options)
end

-- fzf searching
M.map("", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>")
M.map("", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
M.map("", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
M.map("", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
M.map("", "<leader>fb", "<cmd>lua require('telescope.builtin').file_browser()<cr>")

-- easymotion
M.map("", "<leader><leader>j", "<cmd>lua require('hop').hint_lines({direction = require('hop.hint').HintDirection.AFTER_CURSOR})<cr>")
M.map("", "<leader><leader>k", "<cmd>lua require('hop').hint_lines({direction = require('hop.hint').HintDirection.BEFORE_CURSOR})<cr>")
M.map("", "<leader><leader>l", "<cmd>lua require('hop').hint_words({direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true})<cr>")
M.map("", "<leader><leader>h", "<cmd>lua require('hop').hint_words({direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true})<cr>")

api.nvim_command(":command Bd lua MiniBufremove.delete()")
api.nvim_command(":command FixWhitespace lua MiniTrailspace.trim()")

return M
