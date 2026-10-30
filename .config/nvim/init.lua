-- Enable faster Lua module loading (Neovim 0.9+)
vim.loader.enable()

-- {{{ vim.pack (builtin package manager, Neovim 0.12+)

-- build hooks must exist before the first vim.pack.add() so they also fire
-- for plugins installed during startup
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

local function pack_names()
	return vim.iter(vim.pack.get(nil, { info = false }))
		:map(function(p)
			return p.spec.name
		end)
		:totable()
end

-- review and apply updates (all plugins, or only the named ones)
vim.api.nvim_create_user_command("PackUpdate", function(opts)
	vim.pack.update(#opts.fargs > 0 and opts.fargs or nil)
end, { nargs = "*", complete = pack_names })

-- move every plugin to the revision recorded in nvim-pack-lock.json
vim.api.nvim_create_user_command("PackSync", function()
	vim.pack.update(nil, { target = "lockfile" })
end, {})

-- delete installed plugins that this config no longer adds
vim.api.nvim_create_user_command("PackClean", function()
	local stale = vim.iter(vim.pack.get(nil, { info = false }))
		:filter(function(p)
			return not p.active
		end)
		:map(function(p)
			return p.spec.name
		end)
		:totable()

	if #stale == 0 then
		vim.notify("vim.pack: nothing to clean")
		return
	end

	if vim.fn.confirm("Delete " .. table.concat(stale, ", ") .. "?", "&Yes\n&No", 2) == 1 then
		vim.pack.del(stale)
	end
end, {})
-- }}}

-- {{{ helper functions
-- `now()` runs immediately and `later()` defers until after startup; both
-- report errors instead of aborting the rest of init.lua
local function now(f)
	local ok, err = pcall(f)
	if not ok then
		vim.notify(tostring(err), vim.log.levels.ERROR)
	end
end

local function later(f)
	vim.schedule(function()
		now(f)
	end)
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
		winborder = "rounded", -- border on floating windows (hover, signature help, etc.)
		foldmethod = "marker", -- fold by using the parenthesis tags
		foldlevelstart = 99, -- all folds open by default
		swapfile = false, -- disable swap files
	}

	for opt, val in pairs(opts) do
		vim.o[opt] = val
	end
end)
-- }}} vim options

-- {{{ automatically determine indentation via statistics
now(function()
	vim.pack.add({ "https://github.com/nmac427/guess-indent.nvim" })

	require("guess-indent").setup()
end)
-- }}}

-- {{{ color themes
now(function()
	-- {{{ gruvbox
	vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" })

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
	vim.pack.add({ "ssh://git@git.0xdad.com/tblyler/dracula-pro.vim.git" })
	vim.api.nvim_create_user_command("DraculaDark", function(opts)
		vim.o.background = "dark"
		vim.cmd.colorscheme("dracula_pro_van_helsing_protan")
	end, {})

	vim.api.nvim_create_user_command("DraculaLight", function(opts)
		vim.o.background = "light"
		vim.cmd.colorscheme("alucard")
	end, {})
	-- }}}

	vim.o.background = "dark"
	vim.o.termguicolors = true -- enable 24 bit colors

	local color_priorities = {
		"dracula_pro_van_helsing_protan",
		"dracula_pro_van_helsing",
		"gruvbox",
		"default",
	}
	for _, colorscheme in pairs(color_priorities) do
		if pcall(vim.cmd.colorscheme, colorscheme) then
			break
		end
	end
end)
-- }}}

-- {{{ mini.nvim plugins
now(function()
	vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
end)

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

	-- {{{ tpope/vim-surround style aliases on top of mini.surround's sa/sd/sr
	vim.keymap.set("n", "ys", "sa", { remap = true, desc = "Add surrounding" })
	vim.keymap.set("n", "yss", "sa_", { remap = true, desc = "Add surrounding to line" })
	vim.keymap.set("n", "ds", "sd", { remap = true, desc = "Delete surrounding" })
	vim.keymap.set("n", "cs", "sr", { remap = true, desc = "Replace surrounding" })
	vim.keymap.set("x", "S", "sa", { remap = true, desc = "Add surrounding to selection" })
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

	-- use the picker for vim.ui.select() menus (code actions, etc.)
	vim.ui.select = MiniPick.ui_select
	-- }}}
end)
-- }}}

-- }}}

-- {{{ Git
later(function()
	vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

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

	vim.pack.add({ "https://github.com/tpope/vim-fugitive" })
end)
-- }}}

-- {{{ which key
later(function()
	vim.pack.add({ "https://github.com/folke/which-key.nvim" })
end)
-- }}} which key

-- {{{ LSP jazz
later(function()
	vim.pack.add({
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/mason-org/mason-lspconfig.nvim",
		"https://github.com/folke/trouble.nvim",
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/stevearc/conform.nvim", -- formatting
		"https://github.com/mfussenegger/nvim-lint", -- linting
	})

	-- Mason Setup
	require("mason").setup()
	require("mason-lspconfig").setup({
		automatic_enable = true, -- uses vim.lsp.enable() internally (Neovim 0.11+)
		ensure_installed = {
			"lua_ls",
			"gopls",
			"rust_analyzer",
			"ts_ls",
			"pyright",
		},
	})

	-- mise's own language server (`mise lsp`), installed by mise rather than
	-- mason. it ignores TOML files mise doesn't load as config (Cargo.toml,
	-- pyproject.toml, ...), so it's safe to attach to every toml buffer
	vim.lsp.config("mise", {
		cmd = { "mise", "lsp" },
		filetypes = { "toml" },
		root_markers = { "mise.toml", ".git" },
	})
	vim.lsp.enable("mise")

	-- Diagnostic Configuration (enable virtual text)
	vim.diagnostic.config({
		virtual_text = { spacing = 4, prefix = "●" },
		severity_sort = true,
	})

	-- LspAttach Keybindings
	-- Neovim also maps these by default: grn (rename), gra (code action),
	-- grr (references), gri (implementation), grt (type definition),
	-- gO (document symbols), K (hover), and <C-s> (signature help, insert)
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
				lsp_format = "fallback",
				timeout_ms = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			conform.format({ lsp_format = "fallback" })
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
			go = { "golangcilint" },
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
	-- TSUpdate runs from the PackChanged hook at the top of this file
	vim.pack.add({
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	})

	-- On the 'main' branch, nvim-treesitter is a parser manager only.
	-- Highlighting, indentation, and incremental selection are built into Neovim 0.12+.
	local ts_ok, ts = pcall(require, "nvim-treesitter")
	if not ts_ok then
		vim.notify("Failed to load nvim-treesitter", vim.log.levels.WARN)
		return
	end

	ts.setup()

	-- Install missing parsers automatically
	local ensure_installed = {
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
		"rust",
		"scss",
		"sql",
		"ssh_config",
		"terraform",
		"toml",
		"tsv",
		"tsx",
		"typescript",
		"vimdoc",
		"xml",
		"yaml",
	}

	-- already-installed parsers are skipped
	ts.install(ensure_installed)

	-- Enable treesitter highlighting and indentation for all buffers with a parser
	local function enable_treesitter(buf)
		pcall(vim.treesitter.start, buf)
		local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
		if lang and vim.treesitter.query.get(lang, "indents") then
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end

	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			enable_treesitter(args.buf)
		end,
	})

	-- Activate for buffers already open (since this runs in later())
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
			enable_treesitter(buf)
		end
	end

	-- show indentations how I like them, each layer of indentation etc
	vim.pack.add({ "https://github.com/lukas-reineke/indent-blankline.nvim" })

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

-- {{{ markdown rendering
later(function()
	vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

	local ok, render_markdown = pcall(require, "render-markdown")
	if ok then
		render_markdown.setup({})
	else
		vim.notify("Failed to load render-markdown.nvim", vim.log.levels.WARN)
	end
end)
-- }}}
