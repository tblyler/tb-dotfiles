-- Enable faster Lua module loading (Neovim 0.9+)
vim.loader.enable()

-- {{{ Setup mini.nvim's dep manager

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({
	path = {
		package = path_package,
	},
})
-- }}}

-- {{{ helper functions
-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local function colorscheme_exists(colorscheme)
	local success, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
	return success
end
-- }}}

-- {{{ vim options
now(function()
	local opts = {
		-- tabs look like 4 spaces {
		expandtab = false, -- use tabs by default
		tabstop = 4,
		shiftwidth = 4,
		softtabstop = 4,
		-- }
		number = true, -- show line numbers
		mouse = "", -- disable mouse
		laststatus = 2, -- always show the status line
		autoindent = true, -- turn on autoindent
		smarttab = true, -- turn on smart tabs
		incsearch = true, -- turn on incremental search
		ruler = true, -- show ruler on page
		lazyredraw = true, -- make large file bearable
		regexpengine = 1, -- make searching large files bearable
		foldmethod = "marker", -- fold by using the parenthesis tags
		swapfile = false, -- disable swap files
	}

	for opt, val in pairs(opts) do
		vim.o[opt] = val
	end
end)
-- }}} vim options

-- {{{ automatically determine indentation via statistics
now(function()
	add({
		source = "nmac427/guess-indent.nvim",
	})

	require("guess-indent").setup()
end)
-- }}}

-- {{{ color themes
now(function()
	-- {{{ gruvbox
	add({
		source = "ellisonleao/gruvbox.nvim",
	})

	require("gruvbox").setup({
		contrast = "hard",
	})
	vim.api.nvim_create_user_command("GruvboxDark", function(opts)
		vim.o.background = "dark"
		vim.cmd.colorscheme("gruvbox")
	end, {})

	vim.api.nvim_create_user_command("GruvboxLight", function(opts)
		vim.o.background = "light"
		vim.cmd.colorscheme("gruvbox")
	end, {})
	-- }}}

	-- {{{ dracula
	add({
		source = "ssh://git@git.0xdad.com/tblyler/dracula-pro.vim.git",
	})
	vim.api.nvim_create_user_command("DraculaDark", function(opts)
		vim.o.background = "dark"
		vim.cmd.colorscheme("dracula_pro_van_helsing")
	end, {})

	vim.api.nvim_create_user_command("DraculaLight", function(opts)
		vim.o.background = "light"
		vim.cmd.colorscheme("alucard")
	end, {})
	-- }}}

	vim.o.background = "dark"
	vim.o.termguicolors = true -- enable 24 bit colors

	local color_priorities = {
		"dracula_pro_van_helsing",
		"gruvbox",
		"default",
	}
	for _, colorscheme in pairs(color_priorities) do
		if colorscheme_exists(colorscheme) then
			vim.cmd.colorscheme(colorscheme)
			break
		end
	end
end)
-- }}}

-- {{{ mini.nvim plugins
-- {{{ mini.nvim notify
now(function()
	local ok, mini_notify = pcall(require, "mini.notify")
	if ok then
		mini_notify.setup()
		vim.notify = mini_notify.make_notify()
	else
		vim.notify("Failed to load mini.notify", vim.log.levels.WARN)
	end
end)
-- }}}

-- {{{ eager
now(function()
	local setups = {
		icons = {},
		tabline = {},
		statusline = {},
	}

	for plugin, setup in pairs(setups) do
		require("mini." .. plugin).setup(setup)
	end
end)
-- }}}

-- {{{ lazy
later(function()
	local hipatterns = require("mini.hipatterns")

	local setups = {
		bufremove = {},
		comment = {},
		completion = {},
		cursorword = {},
		hipatterns = {
			highlighters = {
				-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

				-- Highlight hex color strings (`#rrggbb`) using that color
				hex_color = hipatterns.gen_highlighter.hex_color(),
			},
		},
		jump = {},
		jump2d = {},
		pairs = {},
		pick = {},
		surround = {},
		trailspace = {},
	}

	for plugin, setup in pairs(setups) do
		require("mini." .. plugin).setup(setup)
	end

	-- {{{ jump key mapping
	local function jumpbefore()
		MiniJump2d.start({
			allowed_lines = {
				cursor_after = false,
			},
		})
	end

	local function jumpafter()
		MiniJump2d.start({
			allowed_lines = {
				cursor_before = false,
			},
		})
	end

	vim.keymap.set("n", "<leader><leader>k", jumpbefore, { noremap = true, silent = true })
	vim.keymap.set("n", "<leader><leader>j", jumpafter, { noremap = true, silent = true })
	-- }}}

	-- {{{ buffer delete command
	vim.api.nvim_create_user_command("Bd", function(opts)
		MiniBufremove.delete()
	end, {})
	-- }}}

	-- {{{ whitespace fix command
	vim.api.nvim_create_user_command("FixWhitespace", function(opts)
		MiniTrailspace.trim()
	end, {})
	-- }}}

	-- {{{ fzf-like control-P binding
	vim.keymap.set("n", "<c-P>", MiniPick.builtin.files, {})
	vim.keymap.set("n", "<C-S-p>", MiniPick.builtin.grep_live, {})
	-- }}}
end)
-- }}}

-- }}}

-- {{{ Git
later(function()
	add({
		source = "lewis6991/gitsigns.nvim",
	})

	local ok, gitsigns = pcall(require, "gitsigns")
	if ok then
		gitsigns.setup({
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				delay = 0,
			},
		})
	else
		vim.notify("Failed to load gitsigns", vim.log.levels.WARN)
	end

	add({
		source = "tpope/vim-fugitive",
	})
end)
-- }}}

-- {{{ which key
later(function()
	add({
		source = "folke/which-key.nvim",
	})
end)
-- }}} which key

-- {{{ LSP jazz
later(function()
	add({ source = "williamboman/mason.nvim" })
	add({ source = "williamboman/mason-lspconfig.nvim" })
	add({ source = "folke/trouble.nvim" })
	add({ source = "neovim/nvim-lspconfig" })
	add({ source = "stevearc/conform.nvim" }) -- formatting
	add({ source = "mfussenegger/nvim-lint" }) -- linting

	-- Mason Setup
	require("mason").setup()
	require("mason-lspconfig").setup({
		automatic_enable = true, -- uses vim.lsp.enable() internally (Neovim 0.11+)
		ensure_installed = {
			"lua_ls",
			"gopls",
			"rust_analyzer",
			"ts_ls",
			"ty",
		},
	})

	-- Diagnostic Configuration (enable virtual text)
	vim.diagnostic.config({
		virtual_text = { spacing = 4, prefix = "●" },
		signs = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
	})

	-- LspAttach Keybindings
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if not client then
				return
			end

			local buffnr = args.buf
			local lsp_key = function(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { silent = true, buffer = buffnr, desc = desc })
			end

			lsp_key("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
			lsp_key("<leader>la", vim.lsp.buf.code_action, "Code action")
			lsp_key("<leader>ld", vim.lsp.buf.type_definition, "Type definition")
			lsp_key("gd", vim.lsp.buf.definition, "Goto Definition")
			lsp_key("gr", vim.lsp.buf.references, "Goto References")
			lsp_key("gI", vim.lsp.buf.implementation, "Goto Implementation")
			lsp_key("gD", vim.lsp.buf.declaration, "Goto Declaration")

			-- LSP-based folding
			if client.server_capabilities.foldingRangeProvider then
				vim.opt_local.foldmethod = "expr"
				vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
			end
		end,
	})

	-- Formatting with conform.nvim (replaces none-ls)
	local conform_ok, conform = pcall(require, "conform")
	if conform_ok then
		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				python = { "ruff_format" },
				lua = { "stylua" },
				go = { "gofmt" },
			},
			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			conform.format({ lsp_fallback = true })
		end, { desc = "Format buffer or selection" })
	else
		vim.notify("Failed to load conform.nvim", vim.log.levels.WARN)
	end

	-- Linting with nvim-lint (replaces none-ls)
	local lint_ok, lint = pcall(require, "lint")
	if lint_ok then
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			python = { "ruff" },
			go = { "golangci_lint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>ll", function()
			lint.try_lint()
		end, { desc = "Trigger linting" })
	else
		vim.notify("Failed to load nvim-lint", vim.log.levels.WARN)
	end

	-- Trouble.nvim Setup
	local trouble_ok, trouble = pcall(require, "trouble")
	if trouble_ok then
		trouble.setup()
		vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { noremap = true, silent = true })
		vim.keymap.set(
			"n",
			"<leader>xd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			{ noremap = true, silent = true }
		)
	else
		vim.notify("Failed to load trouble", vim.log.levels.WARN)
	end
end)
-- }}}

-- {{{ treesitter
later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- Use 'master' while monitoring updates in 'main'
		checkout = "master",
		monitor = "main",
		-- Perform action after every checkout
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})

	-- Possible to immediately execute code which depends on the added plugin
	local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
	if not ts_ok then
		vim.notify("Failed to load nvim-treesitter.configs", vim.log.levels.WARN)
		return
	end

	ts_configs.setup({
		ensure_installed = {
			"bash",
			"c",
			"c_sharp",
			"comment",
			"cpp",
			"css",
			"diff",
			"dockerfile",
			"earthfile",
			"fish",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"go",
			"gomod",
			"gosum",
			"gpg",
			"html",
			"http",
			"ini",
			"java",
			"javascript",
			"jq",
			"jsdoc",
			"json",
			"kotlin",
			"lua",
			"luadoc",
			"make",
			"markdown",
			"markdown_inline",
			"nginx",
			"php",
			"proto",
			"python",
			"regex",
			"robots",
			"rust",
			"scss",
			"sql",
			"ssh_config",
			"terraform",
			"tmux",
			"toml",
			"tsv",
			"tsx",
			"typescript",
			"vimdoc",
			"xml",
			"yaml",
		},
		sync_install = false,
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = { enable = true },
	})

	-- show indentations how I like them, each layer of indentation etc
	add({
		source = "lukas-reineke/indent-blankline.nvim",
	})

	require("ibl").setup({
		indent = {
			char = "▏",
			highlight = { "Label" },
		},
		scope = {
			highlight = { "Function" },
		},
	})
end)
-- }}}
